import os
import sys
import logging.config
import subprocess


def main():
    os.environ['DJANGO_SETTINGS_MODULE'] = 'glados.settings'

    from django.core.management import execute_from_command_line
    from django.conf import settings

    logging.config.dictConfig(settings.LOGGING)

    import glados.static_files_compiler
    import glados.apache_config_generator
    import glados.admin_user_generator
        
    # Compress files before server launch if compression is enabled
    if os.environ.get('RUN_MAIN') != 'true' and len(sys.argv) > 1 and sys.argv[1] == 'runserver' and settings.DEBUG:

        glados.static_files_compiler.StaticFilesCompiler.compile_all_known_compilers()
        execute_from_command_line([sys.argv[0], 'compilemessages'])

    elif os.environ.get('RUN_MAIN') != 'true' and len(sys.argv) > 1 and sys.argv[1] == 'collectstatic':
        
        # # Builds static VueJS app
        # logging.info(subprocess.check_output(['npm', 'run', 'build'], cwd='chemvue'))
        
        glados.static_files_compiler.StaticFilesCompiler.compile_all_known_compilers()
        execute_from_command_line([sys.argv[0], 'compilemessages', '--settings=glados'])
        if settings.COMPRESS_ENABLED and settings.COMPRESS_OFFLINE:
            execute_from_command_line([sys.argv[0], 'compress'])

    elif os.environ.get('RUN_MAIN') != 'true' and len(sys.argv) > 1 and sys.argv[1] == 'createapacheconfig':

        glados.apache_config_generator.generate_config()

    elif os.environ.get('RUN_MAIN') != 'true' and len(sys.argv) > 1 and sys.argv[1] == 'createdefaultadminuser':

        glados.admin_user_generator.generate_admin_user()


    # all our custom commands are listed here so they are not sent to the original manage.py
    execute_in_manage = sys.argv[1] not in ['createapacheconfig', 'createdefaultadminuser', 'simulatedaemon',
                                            'deleteexpiredurls', 'waitunitlworkersarefree', 'deleteexpireddownloads',
                                            'deleteexpiredsearches', 'getpropertiescounts']
    if execute_in_manage:
        execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
