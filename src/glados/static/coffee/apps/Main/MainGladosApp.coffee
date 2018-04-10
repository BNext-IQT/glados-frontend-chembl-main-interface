glados.useNameSpace 'glados.apps.Main',
  MainGladosApp: class ActivitiesBrowserApp

    @showMainSplashScreen = -> $('#GladosMainSplashScreen').show()
    @hideMainSplashScreen = -> $('#GladosMainSplashScreen').hide()
    @showMainGladosContent = ->
      $('#GladosMainContent').show()
      @hideMainSplashScreen()
      
    @baseTemplates:
      main_page: 'Handlebars-MainPageLayout'
      search_results: 'Handlebars-SearchResultsLayout'
      structure_search_results: 'Handlebars-SubstructureSearchResultsLayout'
      browser: 'Handlebars-MainBrowserContent'

    @init = ->

      mainRouter = glados.routers.MainGladosRouter.getInstance()

      #check if there are shortened params
      shortenedURL = $('#GladosShortenedParamsContainer').attr('data-shortened-params')
      if shortenedURL != ''

        Backbone.history.start({silent: true})
        window.history.pushState({}, '', glados.Settings.GLADOS_BASE_PATH_REL+glados.Settings.NO_SIDE_NAV_PLACEHOLDER)
        mainRouter.navigate(shortenedURL, {trigger: true})
      else
        Backbone.history.start()

    @setUpLinkShortenerListener = (containerElem) ->
      if not @mutObserver?
        mutationCallback = (mutationsList) ->

          for mutation in mutationsList
            addedNodes = mutation.addedNodes
            for node in addedNodes
              $node = $(node)
              # check for the current added node
              isAnchor = node.nodeName == 'A'
              if isAnchor
                glados.Utils.URLS.shortenHTMLLinkIfNecessary($node)

              # and also check for check for the added node's descendants
              $node.find('a').each (index) -> glados.Utils.URLS.shortenHTMLLinkIfNecessary($(@))

        @mutObserver = new MutationObserver(mutationCallback)
        observationConfig =
          childList: true
          subtree: true

        @mutObserver.observe(containerElem, observationConfig)

    @prepareContentFor = (pageName, templateParams={}) ->
      #make sure splash screen is shown, specially useful when it changes urls without using the server
      @showMainSplashScreen()

      promiseFunc = (resolve, reject)->
        templateName = @baseTemplates[pageName]
        $gladosMainContent = $('#GladosMainContent')
        $gladosMainContent.empty()

        @setUpLinkShortenerListener($gladosMainContent[0])

        glados.Utils.fillContentForElement($gladosMainContent, templateParams, templateName)
        @showMainGladosContent()
        # This delay is required to allow the browser to render the splash screen
        _.delay resolve, 100

      promiseFunc = promiseFunc.bind(@)

      promise = new Promise( (resolve, reject)->
        # This delay is required to allow the browser to render the splash screen
        _.delay promiseFunc, 100, resolve, reject
      )
      return promise

    # ------------------------------------------------------------------------------------------------------------------
    # Main page
    # ------------------------------------------------------------------------------------------------------------------
    @initMainPage = ->

#      window.location.href = '/main'
#      glados.apps.BreadcrumbApp.setBreadCrumb([], undefined, hideShareButton=true)
#      promise = @prepareContentFor('main_page')
#
#      promise.then ->
#        MainPageApp.init()

    # ------------------------------------------------------------------------------------------------------------------
    # Search Results
    # ------------------------------------------------------------------------------------------------------------------
    @initSearchResults = (currentTab, searchTerm, currentState) ->

      promise = @prepareContentFor('search_results')

      promise.then ->
        SearchResultsApp.init(currentTab, searchTerm, currentState)

    @initSubstructureSearchResults = (searchTerm) ->

      templateParams =
        type: 'Substructure'
      promise = @prepareContentFor('structure_search_results', templateParams)

      promise.then ->
        breadcrumbLinks = [
          {
            label: 'Substructure Search Results'
            link: "#{glados.Settings.SUBSTRUCTURE_SEARCH_RESULTS_PAGE}#{searchTerm}"
          }
        ]

        glados.apps.BreadcrumbApp.setBreadCrumb(breadcrumbLinks)
        SearchResultsApp.initSubstructureSearchResults(searchTerm)

    @initSimilaritySearchResults = (searchTerm, threshold) ->

      templateParams =
        type: 'Similarity'
      promise = @prepareContentFor('structure_search_results', templateParams)

      promise.then ->
        breadcrumbLinks = [
          {
            label: 'Similarity Search Results'
            link: "#{glados.Settings.SIMILARITY_SEARCH_RESULTS_PAGE}#{searchTerm}/#{searchTerm}/#{threshold}"
          }
        ]

        glados.apps.BreadcrumbApp.setBreadCrumb(breadcrumbLinks)
        SearchResultsApp.initSimilaritySearchResults(searchTerm, threshold)

    @initFlexmatchSearchResults = (searchTerm) ->

      templateParams =
        type: ''
      promise = @prepareContentFor('structure_search_results', templateParams)

      promise.then ->
        breadcrumbLinks = [
          {
            label: 'Structure Search Results'
            link: "#{glados.Settings.FLEXMATCH_SEARCH_RESULTS_PAGE}#{searchTerm}/#{searchTerm}"
          }
        ]
        glados.apps.BreadcrumbApp.setBreadCrumb(breadcrumbLinks)
        SearchResultsApp.initFlexmatchSearchResults(searchTerm)

    # ------------------------------------------------------------------------------------------------------------------
    # Entity Browsers
    # ------------------------------------------------------------------------------------------------------------------
    @initBrowserForEntity = (entityName, filter, state) ->

      promise = @prepareContentFor('browser')

      promise.then ->
        reverseDict = {}
        for key, val of glados.Settings.ES_KEY_2_SEARCH_PATH
          reverseDict[val] = key

        reverseDict.activities = 'ACTIVITY'
        reverseDict.drugs = 'DRUGS_LIST'
        # use dict created by jf
        dictKey = reverseDict[entityName]

        if entityName != 'activities' and entityName != 'drugs'
          listConfig = glados.models.paginatedCollections.Settings.ES_INDEXES[dictKey]
        else
          listConfig = glados.models.paginatedCollections.Settings.ES_INDEXES_NO_MAIN_SEARCH[dictKey]

        breadcrumbLinks = [
          {
            label: listConfig.LABEL
            link: listConfig.BROWSE_LIST_URL()
          }
          {
            label: filter
            link: listConfig.BROWSE_LIST_URL(filter)
            is_filter_link: true
            truncate: true
          }
        ]

        glados.apps.BreadcrumbApp.setBreadCrumb(breadcrumbLinks,
          longFilter=filter,
          hideShareButton=false,
          longFilterURL=listConfig.BROWSE_LIST_URL(filter))
        glados.apps.Browsers.BrowserApp.initBrowserForEntity(entityName, filter, state)

    # ------------------------------------------------------------------------------------------------------------------
    # Report Cards
    # ------------------------------------------------------------------------------------------------------------------
    @initReportCard = (entityName, chemblID) ->

      console.log 'INIT REPORT CARD'







