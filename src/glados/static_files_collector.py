"""
Module that provides functions to collect the static files and copy them to their final directory
This is the directory used by the statics file server to publish the files.
"""
import logging
import os
from concurrent import futures
import multiprocessing
import time

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

    thread_pool_executor_tasks = []
    num_files_to_copy = 0

    with futures.ThreadPoolExecutor(max_workers=multiprocessing.cpu_count()) as thread_pool_executor:

        for current_dir, dirs, files in os.walk(top=source_path):

            for current_file in files:
                num_files_to_copy += 1
                current_task = thread_pool_executor.submit(copy_and_compress_file, current_dir, current_file,
                                                           destination_path)

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


def copy_and_compress_file(origin_path, filename, destination_base_path):
    """
    Copies the file from the origin path to the destination base path. Takes into account
    that the file may have been already written or is being written by other process
    :param origin_path: source path of the file
    :param filename: name of the file to copy
    :param destination_base_path: destination dir to copy the file
    :return : True if the destination file was modified, False otherwise
    """


    source_full_path = f'{origin_path}/{filename}'
    logger.info(f'Attempting to copy file from  {source_full_path} to base dir {destination_base_path}')

    logger.info('---')
    return True
