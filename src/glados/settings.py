"""
Django settings for mysite project.

Generated by 'django-admin startproject' using Django 1.9.2.

For more information on this file, see
https://docs.djangoproject.com/en/1.9/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.9/ref/settings/
"""

import os
import glados
from django.utils.translation import ugettext_lazy as _
import logging
import yaml


class GladosSettingsError(Exception):
    """Base class for exceptions in GLaDOS configuration."""
    pass


class RunEnvs(object):
    DEV = 'DEV'
    TRAVIS = 'TRAVIS'
    TEST = 'TEST'
    PROD = 'PROD'


# ----------------------------------------------------------------------------------------------------------------------
# External Resources Defaults (will be overwritten by .yml file)
# ----------------------------------------------------------------------------------------------------------------------
WS_URL = 'https://www.ebi.ac.uk/chembl/api/data'
BEAKER_URL = 'https://www.ebi.ac.uk/chembl/api/utils'
ELASTICSEARCH_EXTERNAL_URL = 'https://www.ebi.ac.uk/chembl/glados-es'
CHEMBL_ES_INDEX_PREFIX = 'chembl_'

# ----------------------------------------------------------------------------------------------------------------------
# Read config file
# ----------------------------------------------------------------------------------------------------------------------

custom_config_file_path = os.getenv('CONFIG_FILE_PATH')
if custom_config_file_path is not None:
    CONFIG_FILE_PATH = custom_config_file_path
else:
    CONFIG_FILE_PATH = 'config.yml'
print('CONFIG_FILE_PATH: ', CONFIG_FILE_PATH)
run_config = yaml.load(open(CONFIG_FILE_PATH, 'r'), Loader=yaml.FullLoader)

RUN_ENV = run_config['run_env']

if RUN_ENV == RunEnvs.DEV:
    print('run_config: ', run_config)

if RUN_ENV not in [RunEnvs.DEV, RunEnvs.TRAVIS, RunEnvs.TEST, RunEnvs.PROD]:
    raise GladosSettingsError("Run environment {} is not supported.".format(RUN_ENV))

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = run_config.get('debug_mode', False)
print('DEBUG: ', DEBUG)

# Build paths inside the project like this: os.path.join(GLADOS_ROOT, ...)
GLADOS_ROOT = os.path.dirname(os.path.abspath(glados.__file__))
print('GLADOS_ROOT: ', )

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.9/howto/deployment/checklist/

BASE_DIR = os.path.dirname(os.path.dirname(__file__))

release_config = run_config.get('current_release')
if release_config is None:
    raise GladosSettingsError("You must provide the current chembl release config")

CURRENT_CHEMBL_RELEASE_NAME = release_config.get('full_name')
if CURRENT_CHEMBL_RELEASE_NAME is None:
    raise GladosSettingsError("You must provide the current release name")

CURRENT_CHEMBL_FULL_DOI = release_config.get('full_doi')
if CURRENT_CHEMBL_FULL_DOI is None:
    raise GladosSettingsError("You must provide the current release doi")

CURRENT_DOWNLOADS_DATE = release_config.get('downloads_date')
if CURRENT_DOWNLOADS_DATE is None:
    raise GladosSettingsError("You must provide the current downloads date ")

DOWNLOADS_RELEASE_NAME = release_config.get('downloads_release_name')
if DOWNLOADS_RELEASE_NAME is None:
    raise GladosSettingsError("You must provide the current downloads base name ")

CHEMBL_ES_INDEX_PREFIX = release_config.get('elasticsearch_chembl_index_prefix')
if DOWNLOADS_RELEASE_NAME is None:
    raise GladosSettingsError("You must provide the current downloads base name ")


# ----------------------------------------------------------------------------------------------------------------------
# ES Proxy API Path
# ----------------------------------------------------------------------------------------------------------------------

ES_PROXY_API_BASE_URL = run_config.get('es_proxy_base_url')
if ES_PROXY_API_BASE_URL is None:
    raise GladosSettingsError("You must provide the es proxy base url")

# ----------------------------------------------------------------------------------------------------------------------
# SERVER BASE PATH
# ----------------------------------------------------------------------------------------------------------------------

SERVER_BASE_PATH = run_config.get('server_base_path', '')
print('SERVER_BASE_PATH: ', SERVER_BASE_PATH)

# ----------------------------------------------------------------------------------------------------------------------
# ChEMBL API
# ----------------------------------------------------------------------------------------------------------------------
chembl_api_config = run_config.get('chembl_api')
if chembl_api_config is None:
    raise GladosSettingsError("You must provide the chembl_api configuration")
else:
    WS_URL = chembl_api_config.get('ws_url')
    BEAKER_URL = chembl_api_config.get('beaker_url')
    if WS_URL is None or BEAKER_URL is None:
        raise GladosSettingsError("You must provide both the web services (data) URL and beaker (utils) URL")


# ----------------------------------------------------------------------------------------------------------------------
# SECURITY WARNING: keep the secret key used in production secret!
# ----------------------------------------------------------------------------------------------------------------------
SECRET_KEY = run_config.get('server_secret_key',
                            'Cake and grief counseling will be available at the conclusion of the test.')

# ----------------------------------------------------------------------------------------------------------------------
# Twitter
# ----------------------------------------------------------------------------------------------------------------------
TWITTER_ENABLED = run_config.get('enable_twitter', False)

if TWITTER_ENABLED:

    twitter_secrets = run_config.get('twitter_secrets')
    if twitter_secrets is None:
        raise GladosSettingsError("You must provide the twitter secrets ")

    TWITTER_ACCESS_TOKEN = twitter_secrets.get('twitter_access_token', '')
    TWITTER_ACCESS_TOKEN_SECRET = twitter_secrets.get('twitter_access_token_secret', '')
    TWITTER_CONSUMER_KEY = twitter_secrets.get('twitter_access_consumer_key', '')
    TWITTER_CONSUMER_SECRET = twitter_secrets.get('twitter_access_consumer_secret', '')

# ----------------------------------------------------------------------------------------------------------------------
# Blogger
# ----------------------------------------------------------------------------------------------------------------------
BLOGGER_ENABLED = run_config.get('enable_blogger', False)
if BLOGGER_ENABLED:
    blogger_secrets = run_config.get('blogger_secrets')
    if blogger_secrets is None:
        raise GladosSettingsError("You must provide the blogger secrets ")

    BLOGGER_KEY = blogger_secrets.get('blogger_key', '')


# ----------------------------------------------------------------------------------------------------------------------
# ElasticSearch
# ----------------------------------------------------------------------------------------------------------------------
elasticsearch_config = run_config.get('elasticsearch')
if elasticsearch_config is None:
    raise GladosSettingsError("You must provide the elasticsearch configuration")
else:
    ELASTICSEARCH_EXTERNAL_URL = elasticsearch_config.get('public_host')
    if ELASTICSEARCH_EXTERNAL_URL is None:
        raise GladosSettingsError("You must provide the elasticsearch public URL that will be accessible from the js "
                                  "code in the browser")

ALLOWED_HOSTS = ['*']

# Application definition

INSTALLED_APPS = [
  'django.contrib.admin',
  'django.contrib.auth',
  'django.contrib.contenttypes',
  'django.contrib.sessions',
  'django.contrib.messages',
  'django.contrib.staticfiles',
  'corsheaders',
  'glados',
  'compressor',
  'twitter',
]

MIDDLEWARE = [
  'corsheaders.middleware.CorsMiddleware',    
  'django.middleware.security.SecurityMiddleware',
  'django.contrib.sessions.middleware.SessionMiddleware',
  'django.middleware.locale.LocaleMiddleware',
  'django.middleware.common.CommonMiddleware',
  'django.middleware.csrf.CsrfViewMiddleware',
  'django.contrib.auth.middleware.AuthenticationMiddleware',
  'django.contrib.messages.middleware.MessageMiddleware',
  'django.middleware.clickjacking.XFrameOptionsMiddleware'
]

CORS_URLS_REGEX = r'^.*/glados_api/.*$'
CORS_ORIGIN_ALLOW_ALL = True

ROOT_URLCONF = 'glados.urls'

TEMPLATES = [
  {
    'BACKEND': 'django.template.backends.django.DjangoTemplates',
    'DIRS': [os.path.join(GLADOS_ROOT, 'templates/'),],
    'APP_DIRS': True,
    'OPTIONS': {
      'context_processors': [
        'django.template.context_processors.debug',
        'django.template.context_processors.request',
        'django.contrib.auth.context_processors.auth',
        'django.contrib.messages.context_processors.messages',
        'glados.settings_context.glados_settings_context_processor',
      ],
      'debug': DEBUG,
    },
  },
]

# ----------------------------------------------------------------------------------------------------------------------
# Database
# https://docs.djangoproject.com/en/1.9/ref/settings/#databases
# ----------------------------------------------------------------------------------------------------------------------
DATABASES = {}

DATABASES = {
  'default': {
    'ENGINE': 'django.db.backends.sqlite3',
    'NAME': os.path.join(GLADOS_ROOT, 'db/db.sqlite3')
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Password validation
# https://docs.djangoproject.com/en/1.9/ref/settings/#auth-password-validators
# ----------------------------------------------------------------------------------------------------------------------

AUTH_PASSWORD_VALIDATORS = [
  {
    'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
  },
  {
    'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
  },
  {
    'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
  },
  {
    'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
  },
]

# ----------------------------------------------------------------------------------------------------------------------
# Internationalization
# https://docs.djangoproject.com/en/1.9/topics/i18n/
# ----------------------------------------------------------------------------------------------------------------------

LANGUAGE_CODE = 'en'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True
LANGUAGES = [
    ('en', _('English')),
]


# ----------------------------------------------------------------------------------------------------------------------
# STATIC FILES (CSS, JavaScript, Images) and URL's
# https://docs.djangoproject.com/en/1.9/howto/static-files/
# ----------------------------------------------------------------------------------------------------------------------

USE_X_FORWARDED_HOST = True

CUSTOM_STATIC_FILES_CONFIG = run_config.get('static_files', {})

STATIC_URL = CUSTOM_STATIC_FILES_CONFIG.get('statics_base_url', f'{SERVER_BASE_PATH}/static/')
print('STATIC_URL: ', STATIC_URL)

STATIC_FILES_SOURCE = CUSTOM_STATIC_FILES_CONFIG.get('static_files_source')
print('STATIC_FILES_SOURCE: ', STATIC_FILES_SOURCE)

if STATIC_FILES_SOURCE is not None:
    STATICFILES_DIRS = (STATIC_FILES_SOURCE,)
else:
    STATICFILES_DIRS = (
        os.path.join(GLADOS_ROOT, 'static/'),
    )

STATIC_ROOT = CUSTOM_STATIC_FILES_CONFIG.get('static_files_destination', os.path.join(GLADOS_ROOT, 'static_root'))
print('STATIC FILES DESTINATION (STATIC_ROOT)', STATIC_ROOT)

STATIC_FILES_SERVER_DESTINATION = CUSTOM_STATIC_FILES_CONFIG.get('static_files_server_destination',
                                                                 os.path.join(GLADOS_ROOT, 'static_root_final'))

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'compressor.finders.CompressorFinder',
)

WATCH_AND_UPDATE_STATIC_COMPILED_FILES = CUSTOM_STATIC_FILES_CONFIG.get('watch_and_update_static_compiled_files', True)
print('WATCH_AND_UPDATE_STATIC_COMPILED_FILES: ', WATCH_AND_UPDATE_STATIC_COMPILED_FILES)

# ----------------------------------------------------------------------------------------------------------------------
# File Compression (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.9/howto/static-files/
# ----------------------------------------------------------------------------------------------------------------------

COMPRESS_ENABLED = CUSTOM_STATIC_FILES_CONFIG.get('enable_statics_compression', False)
print('COMPRESS_ENABLED: ', COMPRESS_ENABLED)

if COMPRESS_ENABLED:
    COMPRESS_OFFLINE = True

    COMPRESS_CSS_FILTERS = ['compressor.filters.css_default.CssAbsoluteFilter',
                            'compressor.filters.cssmin.CSSMinFilter']
    COMPRESS_JS_FILTERS = ['compressor.filters.jsmin.JSMinFilter']
    COMPRESS_URL = STATIC_URL
    COMPRESS_ROOT = STATIC_ROOT
    #COMPRESS_CLOSURE_COMPILER_BINARY = 'java -jar '+ os.path.join(BASE_DIR,
    #'external_tools/closure_compiler/closure-compiler-v20180610.jar')

# ----------------------------------------------------------------------------------------------------------------------
# HTTPS SSL PROXY HEADER
# ----------------------------------------------------------------------------------------------------------------------

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# ----------------------------------------------------------------------------------------------------------------------
# Cache
# ----------------------------------------------------------------------------------------------------------------------
ENABLE_MEMCACHED_CACHE = run_config.get('enable_kubernetes_memcached', False)

if not ENABLE_MEMCACHED_CACHE:

    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
            'LOCATION': '127.0.0.1:11211',
        }
    }
else:

    kubernetes_memcached_config = run_config.get('kubernetes_memcached_config')

    if kubernetes_memcached_config is None:
        raise GladosSettingsError('You must provide a memcached configuration!')

    hosts = kubernetes_memcached_config.get('hosts')
    print('MEMCACHED HOSTS: ', hosts)

    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
            'LOCATION': hosts,
        }
    }

ES_PROXY_CACHE_SECONDS = run_config.get('es_proxy_cache_seconds', 604800)  # 7 days

# ----------------------------------------------------------------------------------------------------------------------
# Logging
# ----------------------------------------------------------------------------------------------------------------------
CUSTOM_LOGGING_CONFIG = run_config.get('logging', {})
DJANGO_DEBUG_LEVEL = CUSTOM_LOGGING_CONFIG.get('django_level', 'INFO')

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'glados': {
            'class': 'glados.logging_helper.MultiLineFormatter',
            'format': '%(asctime)s %(levelname)-8s %(message)s',
            'datefmt': '%Y-%m-%d %H:%M:%S'
        }
    },
    'handlers': {
        'console': {
            'level': logging.DEBUG,
            'class': 'glados.logging_helper.ColoredConsoleHandler',
            'formatter': 'glados',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': os.getenv('DJANGO_LOG_LEVEL', DJANGO_DEBUG_LEVEL),
        },
        'glados.static_files_compiler': {
            'handlers': ['console'],
            'level': logging.DEBUG if WATCH_AND_UPDATE_STATIC_COMPILED_FILES else logging.INFO,
            'propagate': True,
        }
    },
}
