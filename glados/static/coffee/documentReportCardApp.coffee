class DocumentReportCardApp

  # -------------------------------------------------------------
  # Models
  # -------------------------------------------------------------

  @initDocument = (chembl_id) ->
    document = new Document
      document_chembl_id: chembl_id

    document.url = Settings.WS_BASE_URL + 'document/' + chembl_id + '.json'
    return document

  @initDocumentAssayNetwork = (doc_chembl_id) ->
    dan = new DocumentAssayNetwork
      document_chembl_id: doc_chembl_id

    return dan


  # -------------------------------------------------------------
  # Views
  # -------------------------------------------------------------

  ### *
    * Initializes the DBIView (Document Basic Information View)
    * @param {Compound} model, base model for the view
    * @param {JQuery} top_level_elem element that renders the model.
    * @return {DocumentBasicInformationView} the view that has been created
  ###
  @initDBIView = (model, top_level_elem) ->

    dbiView = new DocumentBasicInformationView
      model: model
      el: top_level_elem

    return dbiView


  ### *
    * Initializes the DANView (Document Assay Network View)
    * @param {Compound} model, base model for the view
    * @param {JQuery} top_level_elem element that renders the model.
    * @return {DocumentAssayNetworkView} the view that has been created
  ###
  @initDANView = (model, top_level_elem) ->

    danView = new DocumentAssayNetworkView
      el: top_level_elem
      model: model

    return danView


  ### *
    * Initializes the DANFSView (Document Assay Network Full Screen View)
    * @param {Compound} model, base model for the view
    * @param {JQuery} top_level_elem element that renders the model.
    * @return {DocumentAssayNetworkFSView} the view that has been created
  ###
  @initDANFSView = (model, top_level_elem) ->

    danFSView = new DocumentAssayNetworkFSView
      el: top_level_elem
      model: model

    return danFSView