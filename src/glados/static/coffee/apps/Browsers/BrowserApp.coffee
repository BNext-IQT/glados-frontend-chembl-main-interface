glados.useNameSpace 'glados.apps.Browsers',
  BrowserApp: class BrowserApp

    @init =->

      router = new glados.apps.Browsers.BrowserRouter
      Backbone.history.start()

    @entityListsInitFunctions:
      compounds: glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESCompoundsList\
        .bind(glados.models.paginatedCollections.PaginatedCollectionFactory)
      targets: glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESTargetsList\
        .bind(glados.models.paginatedCollections.PaginatedCollectionFactory)
      assays: glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESAssaysList\
        .bind(glados.models.paginatedCollections.PaginatedCollectionFactory)
      documents: glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESDocumentsList\
        .bind(glados.models.paginatedCollections.PaginatedCollectionFactory)
      cells: glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESCellsList\
        .bind(glados.models.paginatedCollections.PaginatedCollectionFactory)
      tissues: glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESTissuesList\
        .bind(glados.models.paginatedCollections.PaginatedCollectionFactory)
      drugs: glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESDrugsList\
        .bind(glados.models.paginatedCollections.PaginatedCollectionFactory)
      activities: glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESActivitiesList\
        .bind(glados.models.paginatedCollections.PaginatedCollectionFactory)


    # TODO: standardise the entity names from the models
    @entityNames:
      compounds: 'Compounds'
      targets: 'Targets'
      assays: 'Assays'
      documents: 'Documents'
      cells: 'Cells'
      tissues: 'Tissues'
      drugs: 'Drugs'
      activities: 'Activities'

    @initBrowserForEntity = (entityName, filter, state) ->

      console.log 'debug'
      $mainContainer = $('.BCK-main-container')
      $mainContainer.show()

      $browserWrapper = $mainContainer.find('.BCK-browser-wrapper')
      glados.Utils.fillContentForElement $browserWrapper,
        entity_name: @entityNames[entityName]

      $browserWrapper.show()
      #this is temporary, while we figure out how handle the states
      # -----------------learn to handle the state!----------------
      $matrixFSContainer = $mainContainer.find('.BCK-matrix-full-screen')
      if state?
        if state.startsWith('matrix_fs_')
          sourceEntity = state.split('matrix_fs_')[1]
          console.log 'sourceEntity: ', sourceEntity

          $browserWrapper.children().hide()
          $matrixFSContainer.show()

          if sourceEntity == 'Targets'
            filterProperty = 'target_chembl_id'
            aggList = ['target_chembl_id', 'molecule_chembl_id']
          else
            filterProperty = 'molecule_chembl_id'
            aggList = ['molecule_chembl_id', 'target_chembl_id']

          ctm = new glados.models.Activity.ActivityAggregationMatrix
            query_string: filter
            filter_property: filterProperty
            aggregations: aggList

          config = MatrixView.getDefaultConfig sourceEntity

          $matrixContainer = $matrixFSContainer.find('.BCK-CompTargetMatrix')
          new MatrixView
            model: ctm
            el: $matrixContainer
            config: config

          console.log 'fetch atm!!'
          ctm.fetch()

          return
      $matrixFSContainer.hide()
      # -----------------learn to handle the state!----------------

      initListFunction = @entityListsInitFunctions[entityName]
      list = initListFunction(filter)

      $browserContainer = $browserWrapper.find('.BCK-BrowserContainer')

      new glados.views.Browsers.BrowserMenuView
        collection: list
        el: $browserContainer

      list.fetch()

