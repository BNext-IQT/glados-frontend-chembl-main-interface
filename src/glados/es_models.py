from elasticsearch_dsl.connections import connections
from elasticsearch_dsl import DocType, Text
from django.conf import settings
from typing import List

if settings.ELASTICSEARCH_PASSWORD is None:
  connections.create_connection(hosts=[settings.ELASTICSEARCH_HOST])
else:
  connections.create_connection(hosts=[settings.ELASTICSEARCH_HOST],
                                http_auth=(settings.ELASTICSEARCH_USERNAME, settings.ELASTICSEARCH_PASSWORD))


class TinyURLIndex(DocType):
  long_url = Text()
  hash = Text()

  class Meta:
    index = 'chembl_glados_tiny_url'


class ElasticSearchMultiSearchQuery:

  def __init__(self, index, body):
    self.index = index
    self.body = body


def do_multi_search(queries: List[ElasticSearchMultiSearchQuery]):
  try:
    conn = connections.get_connection()
    multi_search_body = []
    for query_i in queries:
      multi_search_body.append({'index': query_i.index})
      multi_search_body.append(query_i.body)
    return conn.msearch(body=multi_search_body)
  except Exception as e:
    raise Exception('ERROR: can\'t retrieve elastic search data!')

