// Generated by CoffeeScript 1.4.0
var DocumentsFromTermList;

DocumentsFromTermList = PaginatedCollection.extend({
  model: Document,
  initUrl: function(term) {
    this.baseUrl = Settings.WS_BASE_URL + 'document_term.json?term_text=' + term + '&order_by=-score';
    this.setMeta('base_url', this.baseUrl, true);
    return this.initialiseSSUrl();
  },
  fetch: function() {
    var checkAllInfoReady, documents, getDocuments, receivedDocs, thisCollection, totalDocs, url;
    this.reset();
    url = this.getPaginatedURL();
    documents = [];
    totalDocs = 0;
    receivedDocs = 0;
    getDocuments = $.getJSON(url);
    thisCollection = this;
    checkAllInfoReady = function() {
      if (receivedDocs === totalDocs) {
        console.log('ALL READY!');
        return thisCollection.trigger('do-repaint');
      }
    };
    getDocuments.done(function(data) {
      var doc, docInfo, _i, _len, _results;
      data.page_meta.records_in_page = data.document_terms.length;
      thisCollection.resetMeta(data.page_meta);
      documents = data.document_terms;
      totalDocs = documents.length;
      _results = [];
      for (_i = 0, _len = documents.length; _i < _len; _i++) {
        docInfo = documents[_i];
        doc = new Document(docInfo);
        thisCollection.add(doc);
        _results.push(doc.fetch({
          success: function() {
            receivedDocs += 1;
            return checkAllInfoReady();
          }
        }));
      }
      return _results;
    });
    return getDocuments.fail(function() {
      return console.log('ERROR!');
    });
  },
  initialize: function() {
    return this.meta = {
      server_side: true,
      page_size: 25,
      current_page: 1,
      available_page_sizes: Settings.TABLE_PAGE_SIZES,
      to_show: [],
      columns: [
        {
          'name_to_show': 'CHEMBL_ID',
          'comparator': 'document_chembl_id',
          'sort_disabled': false,
          'is_sorting': 0,
          'sort_class': 'fa-sort',
          'link_base': '/document_report_card/$$$'
        }, {
          'name_to_show': 'Score',
          'comparator': 'score',
          'sort_disabled': false,
          'is_sorting': 0,
          'sort_class': 'fa-sort',
          'custom_field_template': '<p><b>Score: </b>{{val}}</p>'
        }, {
          'name_to_show': 'Title',
          'comparator': 'title',
          'sort_disabled': false,
          'is_sorting': 0,
          'sort_class': 'fa-sort',
          'custom_field_template': '<p><i>{{val}}</i></p>'
        }, {
          'name_to_show': 'Authors',
          'comparator': 'authors',
          'sort_disabled': false,
          'is_sorting': 0,
          'sort_class': 'fa-sort'
        }, {
          'name_to_show': 'Year',
          'comparator': 'year',
          'sort_disabled': false,
          'is_sorting': 0,
          'sort_class': 'fa-sort'
        }
      ]
    };
  }
});
