glados.useNameSpace 'glados.models.paginatedCollections',
# --------------------------------------------------------------------------------------------------------------------
# Factory for Elastic Search Generic Paginated Results List Collection
# Creates a paginated collection based on:
# - MODEL: which backbone model will parse the json data that comes from elastic search
# - PATH: the index path in the elastic search server
# - COLUMNS: a columns description  used for ordering and the views
# --------------------------------------------------------------------------------------------------------------------
  PaginatedCollectionFactory:
# creates a new instance of a Paginated Collection from Elastic Search
    getNewESResultsListFromState: (stateObject) ->

      basicSettingsPath = stateObject.settings_path
      settings = glados.Utils.getNestedValue(glados.models.paginatedCollections.Settings, basicSettingsPath)
      queryString = stateObject.custom_query
      useQueryString = stateObject.use_custom_query
      searchESQuery = stateObject.searchESQuery
      stickyQuery = stateObject.sticky_query
      itemsList = stateObject.generator_items_list
      textFilter = stateObject.text_filter

      list = @getNewESResultsListFor(settings, queryString, useQueryString, itemsList, ssSearchModel=undefined,
        stickyQuery, searchESQuery, flavour=undefined, textFilter)

      facetsState = stateObject.facets_state

      if facetsState?
        # it will now load the facets state later, after loading the facets config
        list.setMeta('facets_state_to_restore', facetsState)

      return list

    getNewESResultsListFor: (esIndexSettings, customQuery='*', useCustomQuery=false, itemsList, ssSearchModel,
      stickyQuery, searchESQuery, flavour, textFilter) ->

      IndexESPagQueryCollection = glados.models.paginatedCollections.PaginatedCollectionBase\
      .extend(glados.models.paginatedCollections.ESPaginatedQueryCollection)
      .extend(glados.models.paginatedCollections.SelectionFunctions)
      .extend(glados.models.paginatedCollections.SortingFunctions)
      .extend(glados.models.paginatedCollections.ReferenceStructureFunctions)
      .extend(glados.models.paginatedCollections.CacheFunctions)
      .extend(glados.models.paginatedCollections.StateSaving.ESCollectionStateSavingFunctions)
      .extend(glados.models.paginatedCollections.TextFilter.ESCollectionTextFilterFunctions)
      .extend(flavour).extend
        model: esIndexSettings.MODEL

        initialize: ->

          @meta =
            index_name: esIndexSettings.INDEX_NAME
            index: esIndexSettings.PATH
            default_page_size: esIndexSettings.DEFAULT_PAGE_SIZE
            page_size: glados.Settings.CARD_PAGE_SIZES[2]
            available_page_sizes: glados.Settings.CARD_PAGE_SIZES
            current_page: 1
            to_show: []
            browse_list_url: esIndexSettings.BROWSE_LIST_URL
            id_column: esIndexSettings.ID_COLUMN
#            facets_groups: glados.models.paginatedCollections.esSchema.FacetingHandler.initFacetGroups(esIndexSettings.FACETS_GROUPS)
            facets_groups: undefined
            columns: esIndexSettings.COLUMNS
#            columns_description: esIndexSettings.COLUMNS_DESCRIPTION
            permanent_comparators_to_fetch: esIndexSettings.PERMANENT_COMPARATORS_TO_FETCH
            custom_default_card_sizes: esIndexSettings.CUSTOM_DEFAULT_CARD_SIZES
            custom_card_size_to_page_sizes: esIndexSettings.CUSTOM_CARD_SIZE_TO_PAGE_SIZES
            enable_cards_zoom: esIndexSettings.ENABLE_CARDS_ZOOM
            custom_cards_template: esIndexSettings.CUSTOM_CARDS_TEMPLATE
            custom_cards_item_view: esIndexSettings.CUSTOM_CARDS_ITEM_VIEW
            custom_card_item_view_details_columns: esIndexSettings.CUSTOM_CARD_ITEM_VIEW_DETAILS_COLUMNS
            complicate_cards_view: esIndexSettings.COMPLICATE_CARDS_VIEW
            complicate_card_columns: esIndexSettings.COMPLICATE_CARDS_COLUMNS
            download_formats: esIndexSettings.DOWNLOAD_FORMATS
            key_name: esIndexSettings.KEY_NAME
            id_name: esIndexSettings.ID_NAME
            label: esIndexSettings.LABEL
            available_views: esIndexSettings.AVAILABLE_VIEWS
            default_view: esIndexSettings.DEFAULT_VIEW
            config_groups: esIndexSettings.CONFIG_GROUPS
            all_items_selected: false
            selection_exceptions: {}
            custom_query: customQuery
            use_custom_query: useCustomQuery
            model: esIndexSettings.MODEL
            generator_items_list: itemsList
            enable_similarity_maps: esIndexSettings.ENABLE_SIMILARITY_MAPS
            show_similarity_maps: esIndexSettings.SHOW_SIMILARITY_MAPS
            enable_substructure_highlighting: esIndexSettings.ENABLE_SUBSTRUCTURE_HIGHLIGHTING
            show_substructure_highlighting: esIndexSettings.SHOW_SUBSTRUCTURE_HIGHLIGHTING
            sticky_query: stickyQuery
            data_loaded: false
            enable_collection_caching: esIndexSettings.ENABLE_COLLECTION_CACHING
            disable_cache_on_download: esIndexSettings.DISABLE_CACHE_ON_DOWNLOAD
            custom_possible_card_sizes_struct: esIndexSettings.POSSIBLE_CARD_SIZES_STRUCT
            settings_path: esIndexSettings.PATH_IN_SETTINGS
            searchESQuery: searchESQuery
            text_filter: textFilter
            links_to_other_entities: esIndexSettings.LINKS_TO_OTHER_ENTITIES
            sssearch_model: ssSearchModel
            download_columns_group: esIndexSettings.DOWNLOAD_COLUMNS_GROUP
            enable_text_filter: esIndexSettings.ENABLE_TEXT_FILTER
            disable_facets: esIndexSettings.DISABLE_FACETS

          if @getMeta('enable_similarity_maps') or @getMeta('enable_substructure_highlighting')
            @initReferenceStructureFunctions()

          if @getMeta('enable_collection_caching')
            @initCache()
            @on 'reset update', @addModelsInCurrentPage, @

          if ssSearchModel?
            @setMeta('out_of_n', ssSearchModel.get('total_results'))
            @setMeta('size_limit', ssSearchModel.get('size_limit'))

          glados.models.paginatedCollections.PaginatedCollectionBase.prototype.initialize.call(@)

      return new IndexESPagQueryCollection

# creates a new instance of a Paginated Collection from Web Services
    getNewWSCollectionFor: (collectionSettings, filter='', flavour={}) ->
      wsPagCollection = glados.models.paginatedCollections.PaginatedCollectionBase\
      .extend(glados.models.paginatedCollections.WSPaginatedCollection)
      .extend(glados.models.paginatedCollections.SelectionFunctions)
      .extend(glados.models.paginatedCollections.SortingFunctions)
      .extend(glados.models.paginatedCollections.CacheFunctions)
      .extend(flavour).extend

        model: collectionSettings.MODEL
        initialize: ->
          @meta =
            base_url: collectionSettings.BASE_URL
            default_page_size: collectionSettings.DEFAULT_PAGE_SIZE
            page_size: collectionSettings.DEFAULT_PAGE_SIZE
            available_page_sizes: collectionSettings.AVAILABLE_PAGE_SIZES
            current_page: 1
            to_show: []
            id_column: collectionSettings.ID_COLUMN
            columns: collectionSettings.COLUMNS
            columns_description: collectionSettings.COLUMNS_DESCRIPTION
            is_carousel: collectionSettings.IS_CAROUSEL
            all_items_selected: false
            selection_exceptions: {}
            custom_filter: filter
            data_loaded: false
            enable_collection_caching: collectionSettings.ENABLE_COLLECTION_CACHING

          @initialiseUrl()

          @on 'reset', (->
            @setItemsFetchingState(glados.models.paginatedCollections.PaginatedCollectionBase.ITEMS_FETCHING_STATES.ITEMS_READY)
          ), @

          if @getMeta('enable_collection_caching')
            @initCache()
            @on 'reset', @addModelsInCurrentPage, @

          glados.models.paginatedCollections.PaginatedCollectionBase.prototype.initialize.call(@)
          @setConfigState(
            glados.models.paginatedCollections.PaginatedCollectionBase.CONFIGURATION_FETCHING_STATES.CONFIGURATION_READY)

      return new wsPagCollection

# creates a new instance of a Client Side Paginated Collection from either Web Services or elasticsearch, This means that
# the collection gets all the data is in one call and the full list is in the client all the time.
    getNewClientSideCollectionFor: (collectionSettings, generator, flavour={}) ->

      collection = glados.models.paginatedCollections.PaginatedCollectionBase\
      .extend(glados.models.paginatedCollections.ClientSidePaginatedCollection)
      .extend(glados.models.paginatedCollections.SelectionFunctions)
      .extend(glados.models.paginatedCollections.SortingFunctions)
      .extend(flavour).extend

        model: collectionSettings.MODEL

        initialize: ->

          @config = collectionSettings
          @generator = generator
          @meta =
            base_url: collectionSettings.BASE_URL
            default_page_size: collectionSettings.DEFAULT_PAGE_SIZE
            page_size: collectionSettings.DEFAULT_PAGE_SIZE
            current_page: 1
            to_show: []
            id_column: collectionSettings.ID_COLUMN
            columns: collectionSettings.COLUMNS
            columns_description: collectionSettings.COLUMNS_DESCRIPTION
            all_items_selected: false
            selection_exceptions: {}
            data_loaded: false
            model: collectionSettings.MODEL
            is_client_side: true

          @on 'reset', (->
            @setItemsFetchingState(glados.models.paginatedCollections.PaginatedCollectionBase.ITEMS_FETCHING_STATES.ITEMS_READY)
          ), @
          @on 'reset', @resetMeta, @

          if @config.preexisting_models?
            @reset(@config.preexisting_models)

          if @generator?
            generatorProperty = @generator.generator_property
            generatorModel = @generator.model
            filterFunc = @generator.filter
            sortByFunc = @generator.sort_by_function

            generatorModel.on 'change', (->
              models = glados.Utils.getNestedValue(generatorModel.attributes, generatorProperty)
              if filterFunc?
                models = _.filter(models, filterFunc)
              if sortByFunc?
                models = _.sortBy(models, sortByFunc)

              parsedModels = []
              BaseModel = @getMeta('model')
              for model in models
                parsedModel = BaseModel.prototype.parse model
                parsedModels.push parsedModel

              @setItemsFetchingState(glados.models.paginatedCollections.PaginatedCollectionBase.ITEMS_FETCHING_STATES.ITEMS_READY)
              @reset(parsedModels)
            ), @

          glados.models.paginatedCollections.PaginatedCollectionBase.prototype.initialize.call(@)
          if flavour.initialize?
            flavour.initialize.call(@)

          @setConfigState(
            glados.models.paginatedCollections.PaginatedCollectionBase.CONFIGURATION_FETCHING_STATES.CONFIGURATION_READY)

      return new collection


# ------------------------------------------------------------------------------------------------------------------
# Specific instantiation of paginated collections
# ------------------------------------------------------------------------------------------------------------------

    getAllESResultsListDict: () ->
      res_lists_dict = {}
      for key_i, val_i of glados.models.paginatedCollections.Settings.ES_INDEXES
        newList = @getNewESResultsListFor(val_i)
        res_lists_dict[key_i] = newList
        glados.helpers.URLHelper.getInstance().listenToList(newList)
      return res_lists_dict

    getNewESTargetsList: (customQueryString='*') ->
      list = @getNewESResultsListFor(glados.models.paginatedCollections.Settings.ES_INDEXES.TARGET,
        customQueryString, useCustomQuery=true)
      return list

    getNewESCompoundsList: (customQuery='*', itemsList,
      settings=glados.models.paginatedCollections.Settings.ES_INDEXES_NO_MAIN_SEARCH.COMPOUND_COOL_CARDS,
      ssSearchModel) ->

      list = @getNewESResultsListFor(settings, customQuery, useCustomQuery=(not itemsList?), itemsList, ssSearchModel)
      return list

    getNewESActivitiesList: (customQuery='*') ->
      list = @getNewESResultsListFor(glados.models.paginatedCollections.Settings.ES_INDEXES_NO_MAIN_SEARCH.ACTIVITY,
        customQuery, useCustomQuery=true)
      return list

    getNewESDocumentsList: (customQuery='*') ->
      list = @getNewESResultsListFor(glados.models.paginatedCollections.Settings.ES_INDEXES.DOCUMENT,
        customQuery, useCustomQuery=true)
      return list

    getNewESCellsList: (customQuery='*') ->
      list = @getNewESResultsListFor(glados.models.paginatedCollections.Settings.ES_INDEXES.CELL_LINE,
        customQuery, useCustomQuery=true)
      return list

    getNewESTissuesList: (customQuery='*') ->
      list = @getNewESResultsListFor(glados.models.paginatedCollections.Settings.ES_INDEXES.TISSUE,
        customQuery, useCustomQuery=true)
      return list

    getNewESAssaysList: (customQuery='*') ->
      list = @getNewESResultsListFor(glados.models.paginatedCollections.Settings.ES_INDEXES.ASSAY,
        customQuery, useCustomQuery=true)
      return list

    getNewESMechanismsOfActionList: (customQuery,
      listConfig=glados.models.paginatedCollections.Settings.ES_INDEXES_NO_MAIN_SEARCH.MECHANISMS_OF_ACTION) ->

      list = @getNewESResultsListFor(listConfig, customQuery, useCustomQuery=true)
      return list

    getNewESDrugsList: (customQuery='*', itemsList, contextualProperties,
      settings=glados.models.paginatedCollections.Settings.ES_INDEXES_NO_MAIN_SEARCH.DRUGS_LIST,
      searchTerm) ->

      stickyQuery =
        term:
          "_metadata.drug.is_drug": true

      list = @getNewESResultsListFor(settings, customQuery, useCustomQuery=(not itemsList?), itemsList,
        ssSearchModel=undefined, stickyQuery)
      return list

    getNewESDrugIndicationsList: (customQuery='*',
      config=glados.models.paginatedCollections.Settings.ES_INDEXES_NO_MAIN_SEARCH.DRUG_INDICATIONS) ->
      list = @getNewESResultsListFor(config, customQuery, useCustomQuery=true)

      return list

    getNewBlogEntriesList: ->

      config = glados.models.paginatedCollections.Settings.WS_COLLECTIONS.BLOG_ENTRIES_LIST
      flavour = glados.models.paginatedCollections.SpecificFlavours.BlogEntriesList
      list = @getNewWSCollectionFor(config, filter='', flavour)

      return list

    getNewTweetsList: ->

      list = @getNewWSCollectionFor(glados.models.paginatedCollections.Settings.WS_COLLECTIONS.TWEETS_LIST)
      list.initURL = ->
        @baseUrl = "#{glados.Settings.GLADOS_BASE_PATH_REL}tweets"
        @setMeta('base_url', @baseUrl, true)
        @initialiseUrl()

      # ----------------------------------------------------------------------------------------------------------------
      # parse
      # ----------------------------------------------------------------------------------------------------------------
      list.parse = (data) ->
        data.page_meta.records_in_page = data.tweets.length

        rawTweets = data.tweets
        simplifiedTweets = []

        #gets hashtags, mentions and links in tweets and turns them into html <a> tags
        replace_urls_from_entities = (html, urls) ->
          for url in urls
            link = "<a href='#{(url['url'])}'>#{url['display_url']}</a>"
            html = html.replace(url['url'], link)
          return html

        replace_hashtags_from_entities = (html, hashtags) ->
          for hashtag in hashtags
            link = "<a href='https://twitter.com/hashtag/#{(hashtag['text'])}'>##{hashtag['text']}</a>"
            html = html.replace('#' + hashtag['text'], link)
          return html

        replace_mentions_from_entities = (html, mentions) ->
          for mention in mentions
            link = "<a href='https://twitter.com/#{(mention['screen_name'])}'>@#{mention['screen_name']}</a>"
            html = html.replace('@' + mention['screen_name'], link)
          return html


        for t in rawTweets

          html = t.text

          for entityType in _.keys(t.entities)

            entities = t.entities[entityType]

            if entityType == 'urls'
              html = replace_urls_from_entities(html, entities)
            if entityType == 'hashtags'
              html = replace_hashtags_from_entities(html, entities)
            if entityType == 'user_mentions'
              html = replace_mentions_from_entities(html, entities)

          simpleTweet =
            id: t.id
            text: html
            createdAt: t['created_at'].split(' ')[1..2].reverse().join(' ')
            user:
              name: t.user.name
              screenName: t.user.screen_name
              profileImgUrl: t.user.profile_image_url

          simplifiedTweets.push(simpleTweet)

        @setMeta('data_loaded', true)
        @resetMeta(data.page_meta)

        return simplifiedTweets

      # ----------------------------------------------------------------------------------------------------------------
      # end parse
      # ----------------------------------------------------------------------------------------------------------------

      return list

    getNewSimilaritySearchResultsListForCarousel: (customConfig={}) ->
      config = glados.models.paginatedCollections.Settings.WS_COLLECTIONS.COMPOUND_WS_RESULTS_LIST_CAROUSEL

      if customConfig.custom_available_page_sizes?
        config.DEFAULT_PAGE_SIZE = customConfig.custom_available_page_sizes[GlobalVariables.CURRENT_SCREEN_TYPE]
      else
        config.DEFAULT_PAGE_SIZE = glados.Settings.DEFAULT_CAROUSEL_SIZES[GlobalVariables.CURRENT_SCREEN_TYPE]

      list = @getNewWSCollectionFor config

      list.initURL = (term, percentage) ->
        @baseUrl = glados.Settings.WS_BASE_SIMILARITY_SEARCH_URL
        console.log 'base url: ', @baseUrl
        @setMeta('base_url', @baseUrl, true)
        @setMeta('use_post', true)
        @setMeta('extra_params', ['only=molecule_chembl_id'])
        params = {
          similarity: percentage
        }
        if term.startsWith('CHEMBL')
          params['chembl_id'] = term
        else
          params['smiles'] = term

        @setMeta('post_parameters', params)
        @initialiseUrl()


      list.parse = (data) ->
        data.page_meta.records_in_page = data.molecules.length
        @setMeta('data_loaded', true)
        @resetMeta(data.page_meta)

        return data.molecules

      return list

#this list is to get the alternate forms of a compound
    getNewAlternateFormsListForCarousel: ->
      config = glados.models.paginatedCollections.Settings.WS_COLLECTIONS.COMPOUND_WS_RESULTS_LIST_CAROUSEL
      config.DEFAULT_PAGE_SIZE = glados.Settings.DEFAULT_CAROUSEL_SIZES[GlobalVariables.CURRENT_SCREEN_TYPE]
      list = @getNewWSCollectionFor config

      list.parse = (data) ->
        data.page_meta.records_in_page = data.molecule_forms.length
        @setMeta('data_loaded', true)
        @resetMeta(data.page_meta)

        return data.molecule_forms

      list.initURL = (chemblID) ->
        @baseUrl = glados.Settings.WS_BASE_URL + 'molecule_form/' + chemblID + '.json'
        console.log 'base url: ', @baseUrl
        @setMeta('base_url', @baseUrl, true)
        @initialiseUrl()

      return list

    getNewUnichemConnectivityList: ->

      config = glados.models.paginatedCollections.Settings.CLIENT_SIDE_WS_COLLECTIONS.UNICHEM_CONNECTIVITY_LIST
      flavour = glados.models.paginatedCollections.SpecificFlavours.UnichemConnectivityRefsList
      list = @getNewClientSideCollectionFor config, generator=undefined, flavour
      return list

    getNewRelatedDocumentsList: ->

      config = glados.models.paginatedCollections.Settings.CLIENT_SIDE_WS_COLLECTIONS.SIMILAR_DOCUMENTS_IN_REPORT_CARD
      list = @getNewClientSideCollectionFor config
      return list

    getNewStructuralAlertList: ->

      config = glados.models.paginatedCollections.Settings.CLIENT_SIDE_WS_COLLECTIONS.STRUCTURAL_ALERTS_LIST
      config.DEFAULT_PAGE_SIZE = glados.Settings.DEFAULT_CAROUSEL_SIZES[GlobalVariables.CURRENT_SCREEN_TYPE]

      list = @getNewClientSideCollectionFor config
      return list

    getNewStructuralAlertsSetsList: ->
      config = glados.models.paginatedCollections.Settings.CLIENT_SIDE_WS_COLLECTIONS.STRUCTURAL_ALERTS_SETS_LIST
      list = @getNewClientSideCollectionFor config

      list.fetch = ->

        thisCollection = @

        getStructAlerts = $.getJSON(@url, (data) ->
          structAlertsSets = thisCollection.parse(data)
          # here everything is ready
          thisCollection.setMeta('data_loaded', true)
          thisCollection.reset(structAlertsSets)
        )


        getStructAlerts.fail( ->
          console.log('error')
          thisCollection.trigger('error')
        )

      list.parse = (data) ->

        structuralAlertsSets = []
        structualAlertsToPosition = {}
        for structAlert in data.compound_structural_alerts

          setName = structAlert.alert.alert_set.set_name
          setPosition = structualAlertsToPosition[setName]

          newAlert =
            cpd_str_alert_id: structAlert.cpd_str_alert_id
            molecule_chembl_id: structAlert.molecule_chembl_id
            alert_name: structAlert.alert.alert_name
            smarts: structAlert.alert.smarts

          if not setPosition?
            newAlertSet =
              set_name: setName
              alerts_list: [newAlert]
              priority: structAlert.alert.alert_set.priority
            structuralAlertsSets.push newAlertSet
            structualAlertsToPosition[setName] = structuralAlertsSets.length - 1
          else
            structuralAlertsSets[setPosition].alerts_list.push newAlert

        return _.sortBy(structuralAlertsSets, (s) -> return -s.priority)

      list.initURL = (chemblID) ->
        @url = "#{glados.Settings.WS_BASE_URL}compound_structural_alert.json?molecule_chembl_id=#{chemblID}&limit=10000"

      return list

    getNewApprovedDrugsClinicalCandidatesList: ->
      list = @getNewClientSideCollectionFor(glados.models.paginatedCollections.Settings.CLIENT_SIDE_WS_COLLECTIONS.APPROVED_DRUGS_CLINICAL_CANDIDATES_LIST)

      list.initURL = (chembl_id) ->
        @url = glados.Settings.WS_BASE_URL + 'mechanism.json?target_chembl_id=' + chembl_id

      list.fetch = ->
        this_collection = @
        drugMechanisms = []
        drugMechanismsPositions = {}

        console.log 'going to get list of mechs'
        # 1 first get list of drug mechanisms
        getDrugMechanisms = $.getJSON(@url, (data) ->
          drugMechanisms = data.mechanisms

          if drugMechanisms.length > 0
            for i in [0..drugMechanisms.length-1]
              console.log 'i is: ', i
              currentDrug = drugMechanisms[i]
              drugMechanismsPositions[currentDrug.molecule_chembl_id] = i
        )

        getDrugMechanisms.fail(()->
          console.log('error')
          this_collection.trigger('error')
        )

        base_url2 = glados.Settings.WS_BASE_URL + 'molecule.json?molecule_chembl_id__in='
        # after I have the drug mechanisms now I get the molecules
        getDrugMechanisms.done(() ->
          moleculesIDs = (dm.molecule_chembl_id for dm in drugMechanisms).join(',')
          console.log 'drugMechanismsPositions: ', drugMechanismsPositions
          # order is very important to iterate in the same order as the first call
          getMoleculesInfoUrl = base_url2 + moleculesIDs + '&order_by=molecule_chembl_id&limit=1000'

          getMoleculesInfo = $.getJSON(getMoleculesInfoUrl, (data) ->

            molecules = data.molecules
            # Now I fill the missing information
            for mol in molecules

              positionInDrugMechs = drugMechanismsPositions[mol.molecule_chembl_id]
              drugMechanisms[positionInDrugMechs].max_phase = mol.max_phase
              drugMechanisms[positionInDrugMechs].pref_name = mol.pref_name

            # here everything is ready
            this_collection.setMeta('data_loaded', true)
            this_collection.reset(drugMechanisms)
          )

          getMoleculesInfo.fail(()->
            console.log('failed2')
          )
        )

      return list


    getNewTargetRelationsList: ->

      config = glados.models.paginatedCollections.Settings.CLIENT_SIDE_WS_COLLECTIONS.TARGET_RELATIONS_LIST
      flavour = glados.models.paginatedCollections.SpecificFlavours.TargetRelationsList
      list = @getNewClientSideCollectionFor(config, generator=undefined, flavour)

      return list

    getNewTargetComponentsList: ->
      list = @getNewClientSideCollectionFor(glados.models.paginatedCollections.Settings.CLIENT_SIDE_WS_COLLECTIONS.TARGET_COMPONENTS_LIST)

      list.initURL = (chembl_id) ->
        @url = glados.Settings.WS_BASE_URL + 'target/' + chembl_id + '.json'

      list.parse = (response) ->
        @setMeta('data_loaded', true)
        return response.target_components


      return list
