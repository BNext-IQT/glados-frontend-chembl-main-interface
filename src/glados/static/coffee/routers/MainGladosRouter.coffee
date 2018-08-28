glados.useNameSpace 'glados.routers',
  MainGladosRouter: Backbone.Router.extend
    routes:
      '': 'initMainPage'
      'search_results(/:current_tab)(/query=:search_term)(/state=:search_term)': 'initSearchResults'
      'substructure_search_results/:search_term': 'initSubstructureSearchResults'
      'similarity_search_results/:search_term/:threshold': 'initSimilaritySearchResults'
      'flexmatch_search_results/:search_term': 'initFlexmatchSearchResults'
      'browse/:entity_name(/filter/:filter)(/state/:state)': 'initBrowser'
      'browse/:entity_name(/query/:query)(/state/:state)': 'initBrowser'
      'browse/:entity_name(/full_state/:encoded_state)': 'initBrowserFullState'
      'report_card/:entity_name/:chembl_id': 'initReportCard'

    execute: (callback, args, name) ->
      # Always reset the value of this variable on navigation
      GlobalVariables.atSearchResultsPage = false
      if callback?
        callback.apply(@, args)

    initMainPage: -> glados.apps.Main.MainGladosApp.initMainPage()

    initSearchResults: (currentTab, searchTerm, currentState) ->

      glados.helpers.URLHelper.initInstance(glados.helpers.URLHelper.MODES.SEARCH_RESULTS)
      [selectedESEntity, searchTerm, currentState] = \
        glados.routers.MainGladosRouter.validateAndParseSearchURL(currentTab, searchTerm, currentState)
      SearchModel.getInstance().trigger(SearchModel.EVENTS.SEARCH_PARAMS_HAVE_CHANGED, selectedESEntity, searchTerm, currentState)
      GlobalVariables.atSearchResultsPage = true
      glados.apps.Main.MainGladosApp.initSearchResults(selectedESEntity, searchTerm, currentState)

    initSubstructureSearchResults: (searchTerm) ->
      glados.apps.Main.MainGladosApp.initSubstructureSearchResults(searchTerm)

    initSimilaritySearchResults: (searchTerm, threshold) ->
      glados.apps.Main.MainGladosApp.initSimilaritySearchResults(searchTerm, threshold)

    initFlexmatchSearchResults: (searchTerm) ->
      glados.apps.Main.MainGladosApp.initFlexmatchSearchResults(searchTerm)

    initBrowser: (entityName, query, state) ->
      glados.apps.Main.MainGladosApp.initBrowserForEntity(entityName, query, state)

    initBrowserFullState: (entityName, encodedState) ->
      glados.apps.Main.MainGladosApp.initBrowserForEntity(entityName, query=undefined, state=encodedState,
        isFullState=true)

    #-------------------------------------------------------------------------------------------------------------------
    # Report Cards
    #-------------------------------------------------------------------------------------------------------------------
    initReportCard: (entityName, chemblID) ->
      glados.apps.Main.MainGladosApp.initReportCard(entityName, chemblID)
  ,
    #-------------------------------------------------------------------------------------------------------------------
    # STATIC CONTEXT
    #-------------------------------------------------------------------------------------------------------------------

    getInstance: ()->
      if not glados.routers.MainGladosRouter._instance?
        glados.routers.MainGladosRouter._instance = new glados.routers.MainGladosRouter
      return glados.routers.MainGladosRouter._instance

    #-------------------------------------------------------------------------------------------------------------------
    # SEARCH HELPERS
    #-------------------------------------------------------------------------------------------------------------------
    triggerSearchURL: (esEntityKey, searchTerm, currentState) ->

      #this puts the search url in the bar and navigates to it
      newSearchURL = SearchModel.getInstance().getSearchURL(esEntityKey, searchTerm, currentState)
      window.history.pushState({}, 'Search Results', newSearchURL)

      isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent)
      if not isSafari
        window.history.go()
      else
        location.reload(true)

    validateAndParseSearchURL: (tab, searchTerm, state)->
      selectedESEntity = null
      if _.has(glados.Settings.SEARCH_PATH_2_ES_KEY, tab)
        selectedESEntity = glados.Settings.SEARCH_PATH_2_ES_KEY[tab]
      if tab != 'all' and not _.has(glados.Settings.SEARCH_PATH_2_ES_KEY, tab)
        if not searchTerm?
          searchTerm = tab
      return [selectedESEntity, searchTerm, state]


