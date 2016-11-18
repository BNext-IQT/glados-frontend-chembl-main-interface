// Generated by CoffeeScript 1.4.0
var DocumentReportCardApp;

DocumentReportCardApp = (function() {

  function DocumentReportCardApp() {}

  DocumentReportCardApp.init = function() {
    var dWordCloudView, docTerms, document, documentAssayNetwork;
    GlobalVariables.CHEMBL_ID = URLProcessor.getRequestedChemblID();
    document = new Document({
      document_chembl_id: GlobalVariables.CHEMBL_ID
    });
    documentAssayNetwork = new DocumentAssayNetwork({
      document_chembl_id: GlobalVariables.CHEMBL_ID
    });
    new DocumentBasicInformationView({
      model: document,
      el: $('#DBasicInformation')
    });
    docTerms = new DocumentTerms({
      document_chembl_id: GlobalVariables.CHEMBL_ID
    });
    dWordCloudView = new DocumentWordCloudView({
      model: docTerms,
      el: $('#DWordCloudCard')
    });
    new DocumentAssayNetworkView({
      model: documentAssayNetwork,
      el: $('#DAssayNetworkCard')
    });
    document.fetch();
    documentAssayNetwork.fetch();
    docTerms.fetch();
    $('.scrollspy').scrollSpy();
    return ScrollSpyHelper.initializeScrollSpyPinner();
  };

  DocumentReportCardApp.initBasicInformation = function() {
    var document;
    GlobalVariables.CHEMBL_ID = URLProcessor.getRequestedChemblIDWhenEmbedded();
    document = new Document({
      document_chembl_id: GlobalVariables.CHEMBL_ID
    });
    new DocumentBasicInformationView({
      model: document,
      el: $('#DBasicInformation')
    });
    return document.fetch();
  };

  DocumentReportCardApp.initAssayNetwork = function() {
    var documentAssayNetwork;
    GlobalVariables.CHEMBL_ID = URLProcessor.getRequestedChemblIDWhenEmbedded();
    documentAssayNetwork = new DocumentAssayNetwork({
      document_chembl_id: GlobalVariables.CHEMBL_ID
    });
    new DocumentAssayNetworkView({
      model: documentAssayNetwork,
      el: $('#DAssayNetworkCard')
    });
    return documentAssayNetwork.fetch();
  };

  DocumentReportCardApp.initWordCloud = function() {
    var dWordCloudView, docTerms;
    GlobalVariables.CHEMBL_ID = URLProcessor.getRequestedChemblIDWhenEmbedded();
    docTerms = new DocumentTerms({
      document_chembl_id: GlobalVariables.CHEMBL_ID
    });
    dWordCloudView = new DocumentWordCloudView({
      model: docTerms,
      el: $('#DWordCloudCard')
    });
    return docTerms.fetch();
  };

  DocumentReportCardApp.initAssayNetworkFS = function() {
    var danFSView, documentAssayNetwork;
    GlobalVariables.CHEMBL_ID = URLProcessor.getRequestedChemblID();
    documentAssayNetwork = new DocumentAssayNetwork({
      document_chembl_id: GlobalVariables.CHEMBL_ID
    });
    danFSView = new DocumentAssayNetworkFSView({
      model: documentAssayNetwork,
      el: $('#DAN-Main')
    });
    return documentAssayNetwork.fetch();
  };

  return DocumentReportCardApp;

})();
