from django.conf import settings


# Additional variables required for the templates
def glados_settings_context_processor(request):

    absolute_uri = request.build_absolute_uri('/')
    if settings.ENFORCE_HTTPS_IN_ABSOLUTE_URI_FOR_JS:
        absolute_uri = absolute_uri.replace('http', 'https')

    gsc_vars = {
        'request_root_url': absolute_uri,
        'js_debug': 'true' if settings.DEBUG else 'false',
        'ws_url': settings.WS_URL,
        'beaker_url': settings.BEAKER_URL,
        'chembl_es_index_prefix': settings.CHEMBL_ES_INDEX_PREFIX,
        'es_url': settings.ELASTICSEARCH_EXTERNAL_URL,
        'es_proxy_base_url': settings.ES_PROXY_API_BASE_URL
    }
    return gsc_vars
