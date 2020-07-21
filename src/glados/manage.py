import os
import sys
import logging.config


def main():
    os.environ['DJANGO_SETTINGS_MODULE'] = 'glados.settings'

    from django.core.management import execute_from_command_line
    from django.conf import settings

    logging.config.dictConfig(settings.LOGGING)

    import glados.static_files_compiler
    import glados.static_files_collector

    # Compress files before server launch if compression is enabled
    if os.environ.get('RUN_MAIN') != 'true' and len(sys.argv) > 1 and sys.argv[1] == 'runserver' and settings.DEBUG:

        glados.static_files_compiler.StaticFilesCompiler.compile_all_known_compilers()

    elif os.environ.get('RUN_MAIN') != 'true' and len(sys.argv) > 1 and sys.argv[1] == 'collectstatic':

        result = glados.static_files_compiler.StaticFilesCompiler.compile_all_known_compilers()

        if settings.COMPRESS_ENABLED and settings.COMPRESS_OFFLINE:
            execute_from_command_line([sys.argv[0], 'compress'])

    elif os.environ.get('RUN_MAIN') != 'true' and len(sys.argv) > 1 and sys.argv[1] == 'sendstaticstoserver':

        glados.static_files_collector.copy_and_compress_files_to_statics_server()

    # all our custom commands are listed here so they are not sent to the original manage.py
    execute_in_manage = sys.argv[1] not in ['sendstaticstoserver']
    if execute_in_manage:
        execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
