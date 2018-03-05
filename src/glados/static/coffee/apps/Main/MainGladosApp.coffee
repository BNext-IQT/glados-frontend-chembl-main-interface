glados.useNameSpace 'glados.apps.Main',
  MainGladosApp: class ActivitiesBrowserApp

    @showMainSplashScreen = -> $('#GladosMainSplashScreen').show()
    @hideMainSplashScreen = -> $('#GladosMainSplashScreen').hide()
    @showMainGladosContent = -> $('#GladosMainContent').show()

    @baseTemplates:
      main_page: 'Handlebars-MainPageLayout'
      search_results: 'Handlebars-SearchResultsLayout'
      structure_search_results: 'Handlebars-SubstructureSearchResultsLayout'
      browser: 'Handlebars-MainBrowserContent'

    @init = ->

      mainRouter = new glados.routers.MainGladosRouter
      Backbone.history.start()

      window.history.pushState({}, '', glados.Settings.GLADOS_BASE_PATH_REL+glados.Settings.NO_SIDE_NAV_PLACEHOLDER)
      #now if there are shortened params
      shortenedURL = $('#GladosShortenedParamsContainer').attr('data-shortened-params')
      if shortenedURL != ''
        mainRouter.navigate(shortenedURL, {trigger: true})

    @prepareContentFor = (pageName, templateParams={}) ->

      #make sure splash screen is shown, specially useful when it changes urls without using the server
      @showMainSplashScreen()
      templateName = @baseTemplates[pageName]
      $gladosMainContent = $('#GladosMainContent')
      $gladosMainContent.empty()

      glados.Utils.fillContentForElement($gladosMainContent, templateParams, templateName)
      @hideMainSplashScreen()
      @showMainGladosContent()

    # ------------------------------------------------------------------------------------------------------------------
    # Main page
    # ------------------------------------------------------------------------------------------------------------------
    @initMainPage = ->

      @prepareContentFor('main_page')
      MainPageApp.init()

    # ------------------------------------------------------------------------------------------------------------------
    # Search Results
    # ------------------------------------------------------------------------------------------------------------------
    @initSearchResults = (searchTerm) ->

      @prepareContentFor('search_results')
      SearchResultsApp.init(searchTerm)

    @initSubstructureSearchResults = (searchTerm) ->

      templateParams =
        type: 'Substructure'
      @prepareContentFor('structure_search_results', templateParams)
      SearchResultsApp.initSubstructureSearchResults(searchTerm)

    @initSimilaritySearchResults = (searchTerm, threshold) ->

      templateParams =
        type: 'Similarity'
      @prepareContentFor('structure_search_results', templateParams)
      SearchResultsApp.initSimilaritySearchResults(searchTerm, threshold)

    @initFlexmatchSearchResults = (searchTerm) ->

      templateParams =
        type: ''
      @prepareContentFor('structure_search_results', templateParams)
      SearchResultsApp.initFlexmatchSearchResults(searchTerm)


    # ------------------------------------------------------------------------------------------------------------------
    # Entity Browsers
    # ------------------------------------------------------------------------------------------------------------------
    @initBrowserForEntity = (entityName, filter, state) ->

      @prepareContentFor('browser')
      glados.apps.Browsers.BrowserApp.initBrowserForEntity(entityName, filter, state)

    # ------------------------------------------------------------------------------------------------------------------
    # Report Cards
    # ------------------------------------------------------------------------------------------------------------------
    @initReportCard = (entityName, chemblID) ->

      console.log 'INIT REPORT CARD'







