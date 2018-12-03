"""
Django settings for mysite project.

Generated by 'django-admin startproject' using Django 1.9.2.

For more information on this file, see
https://docs.djangoproject.com/en/1.9/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.9/ref/settings/
"""

import os
import sys
import glados
from django.utils.translation import ugettext_lazy as _
import logging


class RunEnvs(object):
    DEV = 'DEV'
    TEST = 'TEST'
    PROD = 'PROD'


RUN_ENV = RunEnvs.DEV

# Build paths inside the project like this: os.path.join(GLADOS_ROOT, ...)
GLADOS_ROOT = os.path.dirname(os.path.abspath(glados.__file__))

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.9/howto/deployment/checklist/

BASE_DIR = os.path.dirname(os.path.dirname(__file__))
# ----------------------------------------------------------------------------------------------------------------------
# SERVER BASE PATH
# ----------------------------------------------------------------------------------------------------------------------


# For usage behind proxies eg: 'chembl/beta/'
SERVER_BASE_PATH = ''

# ----------------------------------------------------------------------------------------------------------------------
# SECURITY WARNING: keep the secret key used in production secret!
# ----------------------------------------------------------------------------------------------------------------------
SECRET_KEY = 'Cake, and grief counseling, will be available at the conclusion of the test.'

# ----------------------------------------------------------------------------------------------------------------------
# Twitter
# ----------------------------------------------------------------------------------------------------------------------

TWITTER_ENABLED = RUN_ENV == RunEnvs.PROD

TWITTER_ACCESS_TOKEN = '<TWITTER_ACCESS_TOKEN>'
TWITTER_ACCESS_TOKEN_SECRET = '<TWITTER_ACCESS_TOKEN_SECRET>'
TWITTER_CONSUMER_KEY = '<TWITTER_CONSUMER_KEY>'
TWITTER_CONSUMER_SECRET = '<TWITTER_CONSUMER_SECRET>'

# ----------------------------------------------------------------------------------------------------------------------
# Blogger
# ----------------------------------------------------------------------------------------------------------------------

BLOGGER_KEY = '<BLOGGER_API_KEY>'


# ----------------------------------------------------------------------------------------------------------------------
# ElasticSearch
# ----------------------------------------------------------------------------------------------------------------------

ELASTICSEARCH_HOST = 'http://wp-p1m-50.ebi.ac.uk:9200'
ELASTICSEARCH_USERNAME = None
ELASTICSEARCH_PASSWORD = None

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = RUN_ENV == RunEnvs.DEV

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
  'django_rq'
]

MIDDLEWARE_CLASSES = [
  'corsheaders.middleware.CorsMiddleware',    
  'django.middleware.security.SecurityMiddleware',
  'django.contrib.sessions.middleware.SessionMiddleware',
  'django.middleware.locale.LocaleMiddleware',
  'django.middleware.common.CommonMiddleware',
  'django.middleware.csrf.CsrfViewMiddleware',
  'django.contrib.auth.middleware.AuthenticationMiddleware',
  'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
  'django.contrib.messages.middleware.MessageMiddleware',
  'django.middleware.clickjacking.XFrameOptionsMiddleware',
  'whitenoise.middleware.WhiteNoiseMiddleware'
]

CORS_URLS_REGEX = r'^/api/.*$'
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

DATABASES = {
  'default': {
    'ENGINE': 'django.db.backends.sqlite3',
    'NAME': os.path.join(GLADOS_ROOT, 'db/db.sqlite3')
  },
  'oradb': {
    'ENGINE':   'django.db.backends.oracle',
    'NAME':     'oradb/xe',
    'USER':     'hr',
    'PASSWORD': 'hr'
  }
}

if 'test' in sys.argv:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': os.path.join(GLADOS_ROOT, 'db/db.sqlite3')
        }        
    }

DATABASE_ROUTERS = ['glados.db.APIDatabaseRouter.APIDatabaseRouter']
# ----------------------------------------------------------------------------------------------------------------------
# Django RQ
# https://github.com/rq/django-rq
# ----------------------------------------------------------------------------------------------------------------------
RQ_QUEUES = {
    'default': {
        'HOST': 'localhost',
        'PORT': 6379,
        'DB': 0,
        'DEFAULT_TIMEOUT': 600,
    },
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
LOCALE_PATHS = [
    os.path.join(GLADOS_ROOT, 'locale'),
]

# ----------------------------------------------------------------------------------------------------------------------
# STATIC FILES (CSS, JavaScript, Images) and URL's
# https://docs.djangoproject.com/en/1.9/howto/static-files/
# ----------------------------------------------------------------------------------------------------------------------

USE_X_FORWARDED_HOST = True

STATIC_URL = '/{0}static/'.format(SERVER_BASE_PATH)

STATICFILES_DIRS = (
  os.path.join(GLADOS_ROOT, 'static/'),
)

STATIC_ROOT = os.path.join(GLADOS_ROOT, 'static_root')

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    #'django.contrib.staticfiles.finders.AppDirectoriesFinder',
    # other finders..
    'compressor.finders.CompressorFinder',
)

WATCH_AND_UPDATE_STATIC_COMPILED_FILES = RUN_ENV != RunEnvs.PROD

# ----------------------------------------------------------------------------------------------------------------------
# File Compression (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.9/howto/static-files/
# ----------------------------------------------------------------------------------------------------------------------

COMPRESS_ENABLED = RUN_ENV == RunEnvs.PROD

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

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
    }
}

# ----------------------------------------------------------------------------------------------------------------------
# Logging
# ----------------------------------------------------------------------------------------------------------------------


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
            'level': os.getenv('DJANGO_LOG_LEVEL', 'INFO'),
        },
        'elasticsearch': {
            'level': logging.CRITICAL
        },
        'glados.static_files_compiler': {
            'handlers': ['console'],
            'level': logging.DEBUG if WATCH_AND_UPDATE_STATIC_COMPILED_FILES else logging.INFO,
            'propagate': True,
        },
        'glados.es_connection': {
            'handlers': ['console'],
            'level': logging.INFO,
            'propagate': True,
        },
    },
}
