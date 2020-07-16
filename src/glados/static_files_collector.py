"""
Module that provides functions to collect the static files and copy them to their final directory
This is the directory used by the statics file server to publish the files.
"""
import logging
import os
from concurrent import futures
import multiprocessing
import time
import hashlib
import shutil
import gzip
from datetime import datetime, timezone, timedelta
import json

from django.conf import settings

logger = logging.getLogger('glados.static_files_compiler')


def copy_and_compress_files_to_statics_server():
    """
    Takes the files in STATIC_ROOT and copies them to STATIC_FILES_SERVER_DESTINATION
    so the static files server can publish them.
    It also compresses the files so the server doesn't have to compress them on the fly.
    Since this is run by an init Container, and can be run in parallel when k8s decides to
    spawn more pods, it can handle this situations and do the copy only once.
    """
    start_time = time.time()

    source_path = settings.STATIC_ROOT
    destination_path = settings.STATIC_FILES_SERVER_DESTINATION
    logger.info(f'Starting to copy files from {source_path} to {destination_path}')
    os.makedirs(destination_path, exist_ok=True)

    thread_pool_executor_tasks = []
    num_files_to_copy = 0

    with futures.ThreadPoolExecutor(max_workers=multiprocessing.cpu_count()) as thread_pool_executor:

        for current_dir, dirs, files in os.walk(top=source_path):

            for current_file in files:
                num_files_to_copy += 1
                current_task = thread_pool_executor.submit(copy_and_compress_file, current_dir, current_file,
                                                           source_path, destination_path)

                thread_pool_executor_tasks.append(current_task)

        thread_pool_executor.shutdown(wait=True)

    copied_files = 0
    skipped_files = 0
    for task in thread_pool_executor_tasks:
        was_copied = task.result()
        if was_copied:
            copied_files += 1
        else:
            skipped_files += 1

    end_time = time.time()
    time_taken = end_time - start_time
    logger.info(
        f'RESULT: {copied_files} copied, {skipped_files} skipped, {num_files_to_copy} analysed. '
        f'Took {time_taken} seconds.'
    )


def copy_and_compress_file(origin_path, filename, source_base_path, destination_base_path):
    """
    Copies the file from the origin path to the destination base path. Takes into account
    that the file may have been already written or is being written by other process
    :param origin_path: source path of the file
    :param filename: name of the file to copy
    :param source_base_path: source base path of the files
    :param destination_base_path: destination dir to copy the file
    :return : True if the destination file was modified, False otherwise
    """

    source_full_path = f'{origin_path}/{filename}'
    source_relative_path = source_full_path.replace(source_base_path, '')
    destination_full_path = f'{destination_base_path}{source_relative_path}'
    destination_full_md5_path = f'{destination_full_path}.md5'
    destination_full_lock_path = f'{destination_full_path}.lock.json'

    logger.info(f'Attempting to copy file from {source_full_path} to {destination_full_path} '
                f'MD5 File: {destination_full_md5_path} Lock File: {destination_full_lock_path}')

    new_md5 = get_md5_of_file(source_full_path)
    md5_exists = os.path.exists(destination_full_md5_path)
    if md5_exists:
        old_md5 = read_md5_file(destination_full_md5_path)
        file_changed = new_md5 != old_md5
        if not file_changed:
            logger.info(f'{destination_full_path} has not changed')
            return False


    lock_exists = os.path.exists(destination_full_lock_path)
    if lock_exists:
        lock_expiration_date = get_lock_expiration_date(destination_full_lock_path)
        now = datetime.utcnow().replace(tzinfo=timezone.utc)
        lock_is_valid = lock_expiration_date > now
        if lock_is_valid:
            logger.info(f'{destination_full_lock_path} lock exists and is still valid')
            return False

    destination_dir = os.path.dirname(destination_full_path)
    os.makedirs(destination_dir, exist_ok=True)

    create_lock_file(destination_full_lock_path)
    do_copy_file(source_full_path, destination_full_path)
    gz_compress_file(destination_full_path)
    write_md5_file(new_md5, destination_full_md5_path)
    os.remove(destination_full_lock_path)

    return True


def get_md5_of_file(file_path):
    """
    :param file_path: path of the file for which to ge the hash
    :return: md5 hash of the file pointed by the given path
    """
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as file:
        for chunk in iter(lambda: file.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


def write_md5_file(md5_hash, md5_file_path):
    """
    writes the md5 hash to the file path indicated as parameter
    :param md5_hash: md5 to save
    :param md5_file_path: path where to save the md5 value
    """

    with open(md5_file_path, 'wt') as file:
        file.write(md5_hash)


def read_md5_file(md5_file_path):
    """
    reads the md5 hash of the file path indicated as parameter
    :param md5_file_path: path for which to read the md5 value
    """

    with open(md5_file_path, 'rt') as file:
        return file.read()


def do_copy_file(source_path, destination_path):
    """
    copies the file from the source to the destination
    :param source_path: source path of the file
    :param destination_path: destination path
    """
    shutil.copyfile(source_path, destination_path)


def gz_compress_file(file_path):
    """
    compresses the file pointed by the path given as parameter
    :param file_path: path of the file to compress
    """
    compressed_path = f'{file_path}.gz'

    with open(file_path, 'rb') as uncompressed_file:
        with gzip.open(compressed_path, 'wb') as file_out:
            shutil.copyfileobj(uncompressed_file, file_out)

    logger.info(f'file compressed: {compressed_path}')


def create_lock_file(lock_file_path):
    """
    creates a lock file in case other process attempts to do the copy
    :param lock_file_path: path of the lock file to create
    """

    lock_expiration_seconds = 20

    now = datetime.utcnow().replace(tzinfo=timezone.utc)
    time_delta = timedelta(seconds=lock_expiration_seconds)
    expiration_date = now + time_delta

    lock = {
        'expires': expiration_date.timestamp() * 1000
    }

    with open(lock_file_path, 'wt') as file:
        json.dump(lock, file)


def get_lock_expiration_date(lock_file_path):
    """
    Reads the the lock file and returns the expiration date
    :return: the expiration date
    """
    with open(lock_file_path, 'rt') as file:
        lock = json.load(file)
        expiration_date = datetime.utcfromtimestamp(lock['expires'] / 1000).replace(tzinfo=timezone.utc)
        return expiration_date
