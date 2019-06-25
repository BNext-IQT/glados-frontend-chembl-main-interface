from django.test import TestCase
from glados.api.chembl.dynamic_downloads.models import DownloadJob
import json
import os
from django.conf import settings


class DownloadJobsServiceTester(TestCase):

    def setUp(self):
        DownloadJob.objects.all().delete()

    def tearDown(self):
        DownloadJob.objects.all().delete()

    def test_queues_simple_download_job(self):

        print('TEST QUEUES SIMPLE DOWNLOAD JOB')

        test_search_context_path = os.path.join(settings.SSSEARCH_RESULTS_DIR, 'test_search_context.json')
        test_raw_context = [{
            'molecule_chembl_id': 'CHEMBL59',
            'similarity': 100.0
        }]

        with open(test_search_context_path, 'wt') as test_search_file:
            test_search_file.write(json.dumps(test_raw_context))

        index_name = 'chembl_molecule'
        raw_query = '{"query_string": {"query": "molecule_chembl_id:(CHEMBL59)"}}'
        desired_format = 'csv'
        context_id = 'test_search_context'
        


        # TODO: a job must exist in queued state
        # TODO: the job id reported must be the one generated by the job id model

    # TODO: test fails when format is not valid



