from django.conf.urls import include, url

urlpatterns = [
    url(r'sssearch/', include('glados.api.chembl.sssearch.urls')),
]
