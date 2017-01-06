from django.conf import settings
import os
import re
import glados
from concurrent import futures
import scss
import coffeescript
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import math

class FileCompilerEventHandler(FileSystemEventHandler):

    def __init__(self, compile_func):
        super(FileCompilerEventHandler, self).__init__()
        self.compile_func = compile_func

    def on_created(self, event):
        super(FileCompilerEventHandler, self).on_created(event)
        self.compile_func(event)

    def on_modified(self, event):
        super(FileCompilerEventHandler, self).on_modified(event)
        self.compile_func(event)


class StaticFilesCompiler(object):

    GLADOS_ROOT = os.path.dirname(os.path.abspath(glados.__file__))
    COFFEE_PATH = os.path.join(GLADOS_ROOT, 'static/coffee')
    COFFEE_GEN_PATH = os.path.join(GLADOS_ROOT, 'static/js/coffee-gen')

    @staticmethod
    def compile_coffee_bare(file_path):
        return coffeescript.compile_file(file_path, bare=True)

    COFFEE_COMPILE_FUNC = compile_coffee_bare

    SCSS_PATH = os.path.join(GLADOS_ROOT, 'static/scss')
    SCSS_GEN_PATH = os.path.join(GLADOS_ROOT, 'static/css/scss-gen')
    SCSS_COMPILE_FUNC = scss.Compiler().compile

    @staticmethod
    def compile_coffee():
        print("If coffee static files compilation takes longer than 10 seconds,\n"
              "please install nodejs to increase compilation speed!")
        StaticFilesCompiler(StaticFilesCompiler.COFFEE_COMPILE_FUNC,
                            StaticFilesCompiler.COFFEE_PATH,
                            StaticFilesCompiler.COFFEE_GEN_PATH,
                            '.coffee', '.js')

    @staticmethod
    def compile_scss():
        StaticFilesCompiler(StaticFilesCompiler.SCSS_COMPILE_FUNC,
                            StaticFilesCompiler.SCSS_PATH,
                            StaticFilesCompiler.SCSS_GEN_PATH,
                            '.scss','.css', exclude_regex_str="^_.*")

    def __init__(self, compiler_function, src_path, out_path, ext_to_compile, ext_replace, exclude_regex_str=None):
        self.compiler_function = compiler_function
        self.src_path = src_path
        self.out_path = out_path
        self.ext_to_compile = ext_to_compile
        self.ext_replace = ext_replace
        if len(self.ext_replace) > 1 and self.ext_replace[0] != ".":
            self.ext_replace = "."+self.ext_replace
        self.exclude_regex_str = exclude_regex_str
        self.exclude_regex = None
        if self.exclude_regex_str:
            self.exclude_regex = re.compile(self.exclude_regex_str)
        self.compile_all()
        self.watch = settings.WATCH_AND_UPDATE_STATIC_COMPILED_FILES
        if self.watch:
            self.file_event_handler = FileCompilerEventHandler(self.watchdog_event_handler)
            self.observer = Observer()
            self.observer.daemon = True
            self.start_watchers()

    def watchdog_event_handler(self, event):
        if not event.is_directory:
            compiled_dir_path = self.get_compiled_path(os.path.dirname(event.src_path))
            compiled_out_path = self.get_compiled_out_path(os.path.basename(event.src_path), compiled_dir_path)
            if compiled_out_path is not None:
                print("COMPILING: {0}\nINTO: {1}\n".format(event.src_path, compiled_out_path))
                self.compile_and_save(event.src_path, compiled_out_path)

    def start_watchers(self):
        self.observer.schedule(self.file_event_handler, self.src_path, recursive=True)
        self.observer.start()

    def compile_and_save(self, file_in, file_out):
        try:
            compile_result = self.compiler_function(file_in)
            with open(file_out, 'w') as file_out_i:
                file_out_i.write(compile_result)
        except Exception as e:
            print("WARNING: Failed to compile file: {0}".format(file_in))
            print(e)

    def get_compiled_path(self, dir_path):
        rel_path = os.path.relpath(dir_path, self.src_path)
        compiled_dir_path = os.path.join(self.out_path, rel_path)
        return compiled_dir_path

    def get_compiled_out_path(self, file_src_name, compiled_dir_path):
        file_i_name, file_i_ext = os.path.splitext(file_src_name)
        if file_i_ext != self.ext_to_compile:
            compiled_out_path = None
        else:
            compiled_out_path = os.path.normpath(
                                                  os.path.join(compiled_dir_path,
                                                               file_i_name+self.ext_replace)
                                                 )
        return compiled_out_path

    def compile_all(self):
        import time
        t_ini = time.time()
        with futures.ThreadPoolExecutor(max_workers=5) as tpe:
            print("Compiling {0} files.".format(self.ext_to_compile))
            for cur_dir, dirs, files in os.walk(top=self.src_path):
                compiled_dir_path = self.get_compiled_path(cur_dir)
                mkdirs_called = False
                for file_i in files:
                    if self.exclude_regex is not None and self.exclude_regex.match(file_i):
                        continue
                    # only create dirs and files if the compilation is successful and the files are not excluded
                    if not mkdirs_called:
                        os.makedirs(compiled_dir_path, exist_ok=True)
                        mkdirs_called = True
                    file_src_i = os.path.join(cur_dir, file_i)
                    compiled_out_path = self.get_compiled_out_path(file_i, compiled_dir_path)
                    if compiled_out_path is not None:
                        tpe.submit(self.compile_and_save, file_src_i, compiled_out_path)
            tpe.shutdown(wait=True)
            print("{0} files compiled in {1} seconds.".format(self.ext_to_compile, math.floor(time.time()-t_ini+1)))
