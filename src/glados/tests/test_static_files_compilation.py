import unittest
import os

import glados.static_files_compiler


class StaticFilesCompilerTester(unittest.TestCase):

    def setUp(self):
        os.environ['DJANGO_SETTINGS_MODULE'] = 'glados.settings'
        print('Running Test: {0}'.format(self._testMethodName))

    def tearDown(self):
        print('Test {0}'.format('Passed!' if self._outcome.success else 'Failed!'))

    def test_compiling_scss(self):
        compiled_correctly = glados.static_files_compiler.StaticFilesCompiler.compile_scss()
        self.assertTrue(compiled_correctly, 'Some SCSS files failed to compile correctly!')

    def test_compiling_coffee(self):
        compiled_correctly = glados.static_files_compiler.StaticFilesCompiler.compile_coffee()
        self.assertTrue(compiled_correctly, 'Some CoffeeScript files failed to compile correctly!')
