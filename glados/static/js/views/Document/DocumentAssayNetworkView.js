// Generated by CoffeeScript 1.4.0
var DocumentAssayNetworkView;

DocumentAssayNetworkView = CardView.extend(ResponsiviseViewExt).extend(DANViewExt).extend(DownloadViewExt).extend({
  initialize: function() {
    var updateViewProxy;
    this.$vis_elem = $('#AssayNetworkVisualisationContainer');
    updateViewProxy = this.setUpResponsiveRender();
    this.model.on('change', updateViewProxy, this);
    return this.resource_type = 'Document';
  },
  render: function() {
    console.log('render! DAN');
    this.showVisibleContent();
    this.hidePreloader();
    this.addFSLinkAndInfo();
    this.paintMatrix();
    this.initEmbedModal('assay_network');
    return this.activateModals();
  },
  addFSLinkAndInfo: function() {
    $(this.el).find('.fullscreen-link').html(Handlebars.compile($('#Handlebars-Document-DAN-FullScreenLink').html())({
      chembl_id: this.model.get('document_chembl_id')
    }));
    return $(this.el).find('.num-results').html(Handlebars.compile($('#Handlebars-Document-DAN-NumResults').html())({
      num_results: this.model.get('graph').nodes.length
    }));
  },
  getFilename: function(format) {
    if (format === 'csv') {
      return this.model.get('document_chembl_id') + 'DocumentAssayNetwork.csv';
    } else if (format === 'json') {
      return this.model.get('document_chembl_id') + 'DocumentAssayNetwork.json';
    } else if (format === 'xlsx') {
      return this.model.get('document_chembl_id') + 'DocumentAssayNetwork.xlsx';
    } else {
      return 'file.txt';
    }
  }
});
