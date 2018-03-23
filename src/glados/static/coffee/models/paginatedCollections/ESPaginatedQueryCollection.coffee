glados.useNameSpace 'glados.models.paginatedCollections',

  # --------------------------------------------------------------------------------------------------------------------
  # This class implements the pagination, sorting and searching for a collection in ElasticSearch
  # extend it to get a collection with the extra capabilities
  # --------------------------------------------------------------------------------------------------------------------
  ESPaginatedQueryCollection: Backbone.Collection.extend
    # ------------------------------------------------------------------------------------------------------------------
    # Backbone Override
    # ------------------------------------------------------------------------------------------------------------------

    errorHandler: (collection, response, options)->
      @resetMeta(0, 0)
      @reset()

    # ------------------------------------------------------------------------------------------------------------------
    # Parse/Fetch Collection data
    # ------------------------------------------------------------------------------------------------------------------

    simplifyHighlights: (highlights)->
      gs_data = glados.models.paginatedCollections.esSchema.GLaDOS_es_GeneratedSchema[@getMeta('index_name')]
      simplifiedHL = {}
      for propPath in _.keys(highlights)
        hlData = highlights[propPath]
        for suffixJ in glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_SUFFIXES_TO_REMOVE
          if suffixJ instanceof RegExp
            propPath = propPath.replace suffixJ, ''
          else if propPath.endsWith suffixJ
            propPath = propPath.replace new RegExp('\.'+suffixJ+'$'), ''
        if not _.has simplifiedHL, propPath
          simplifiedHL[propPath] = {}
        for hlK in hlData
          simpleHlK = hlK.replace(
            new RegExp(
              glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_OPEN_TAG_REGEX_ESCAPED, 'g'
            ), ''
          )
          simpleHlK = simpleHlK.replace(
            new RegExp(
              glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_CLOSE_TAG_REGEX_ESCAPED, 'g'
            ), ''
          )
          included = false
          _.each _.keys(simplifiedHL[propPath]), (keyJ, indexJ, keysList) ->
            included |= keyJ.includes(simpleHlK) or simpleHlK.includes(keyJ)
          if not included
            simplifiedHL[propPath][simpleHlK] = hlK
      for propPath in _.keys(simplifiedHL)
        maxValueLength = 0
        _.each _.values(simplifiedHL[propPath]), (valueJ, indexJ, valuesList) ->
          if valueJ.length > 0
            maxValueLength = valueJ.length

        joinStr = ', '
        if maxValueLength > glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_MAX_WORD_LENGTH * 10
          joinStr = ' .... '

        label = propPath
        label_mini = propPath
        if gs_data[propPath]?
          label = django.gettext(gs_data[propPath].label_id)
          label_mini = django.gettext(gs_data[propPath].label_mini_id)


        hlValue =  Array.from(_.values(simplifiedHL[propPath])).join(joinStr)
        miniHLValue = hlValue
        if hlValue.length > glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_MAX_WORD_LENGTH * 10
          firstSimplified = _.keys(simplifiedHL[propPath])[0].trim()
          firstComplete = _.values(simplifiedHL[propPath])[0].trim()
          startsHighlighted = firstComplete.startsWith(
            glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_OPEN_TAG
          )
          endsHighlighted = firstComplete.startsWith(
            glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_CLOSE_TAG
          )

          simpleHlKWords = firstSimplified.split(/([^a-zA-Z0-9]|\s)/)

          firstWord = simpleHlKWords[0]
          firstWord = firstWord.substring(
            -1, glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_MAX_WORD_LENGTH
          )
          if startsHighlighted
            firstWord = glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_OPEN_TAG + firstWord +
              glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_CLOSE_TAG

          lastWord = simpleHlKWords[simpleHlKWords.length - 1]
          lastWord = lastWord.substring(
            -1, glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_MAX_WORD_LENGTH
          )
          if endsHighlighted
            lastWord = glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_OPEN_TAG + lastWord +
              glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_CLOSE_TAG

          tagIdx = firstComplete.indexOf(
            glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_OPEN_TAG
          ) + glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_OPEN_TAG.length
          closeTagIdx = firstComplete.indexOf(
            glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_CLOSE_TAG
          )
          firstTag = firstComplete.substring(
            tagIdx, closeTagIdx
          )

          firstTag = firstTag.substring(
            -1, glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_MAX_WORD_LENGTH
          )

          firstTag = glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_OPEN_TAG + firstTag +
            glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_CLOSE_TAG

          tagCount = (firstComplete.match(new RegExp(
              glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_OPEN_TAG_REGEX_ESCAPED, 'g'
            ), ''
          ) || []).length

          miniHLValue = firstWord + ' ... ' + firstTag + ' ...'
          if tagCount == 1 and (startsHighlighted or endsHighlighted)
            miniHLValue = firstWord + ' ... ' + lastWord
          if tagCount == 2 and (startsHighlighted and endsHighlighted)
            miniHLValue = firstWord + ' ... ' + lastWord

        simplifiedHL[propPath] = {
          value_mini: miniHLValue
          value: hlValue
          label: label
          label_mini: label_mini
          active_tooltip: miniHLValue != hlValue
        }
      return simplifiedHL

    # Parses the Elastic Search Response and resets the pagination metadata
    parse: (data) ->

      lastPageResultsIds = null
      lastPageResultsIds = @getMeta('last_page_results_ids')
      if not lastPageResultsIds?
        lastPageResultsIds = {}
      curPageResultsIds = {}

      @resetMeta(data.hits.total, data.hits.max_score)
      @setMeta('data_loaded', true)
      jsonResultsList = []

      idAttribute = @getMeta('model').ID_COLUMN.comparator
      scores = @getMeta('scores')

      pageChanged = false
      for hitI in data.hits.hits
        if not _.has(lastPageResultsIds, hitI._id)
          pageChanged = true
        curPageResultsIds[hitI._id] = true

        currentItemData = hitI._source
        currentItemData._highlights = if hitI.highlight? then @simplifyHighlights(hitI.highlight) else null
        currentItemData._score = hitI._score

        if not currentItemData._score? and scores?
          currentItemData._score = scores[currentItemData[idAttribute]]

        if @getMeta('enable_similarity_maps')
          currentItemData.enable_similarity_map = @getMeta('enable_similarity_maps')
          currentItemData.reference_smiles = @getMeta('reference_smiles')
          currentItemData.reference_smiles_error = @getMeta('reference_smiles_error')
          currentItemData.reference_smiles_error_jqxhr = @getMeta('reference_smiles_error_jqxhr')

        if @getMeta('enable_substructure_highlighting')
          currentItemData.enable_substructure_highlighting = @getMeta('enable_substructure_highlighting')
          currentItemData.reference_smiles = @getMeta('reference_smiles')
          currentItemData.reference_ctab = @getMeta('reference_ctab')
          currentItemData.reference_smarts = @getMeta('reference_smarts')
          currentItemData.reference_smiles_error = @getMeta('reference_smiles_error')
          currentItemData.reference_smiles_error_jqxhr = @getMeta('reference_smiles_error_jqxhr')

        jsonResultsList.push(currentItemData)
      if not pageChanged
        pageChanged = _.keys(lastPageResultsIds).length != _.keys(curPageResultsIds).length
      @setMeta('page_changed', pageChanged)


      if not @getMeta('ignore_score')
        #Triggers the event after the values have been updated
        @trigger('score_and_records_update')
      else
        @setMeta('ignore_score', false)

      @setMeta('last_page_results_ids', curPageResultsIds)

      return jsonResultsList

    # Prepares an Elastic Search query to search in all the fields of a document in a specific index
    fetch: (options, testMode=false) ->

      @trigger('before_fetch_elastic')
      @url = @getURL()

      if @getMeta('facets_changed')
        @resetCache() unless not @getMeta('enable_collection_caching')
        @invalidateAllDownloadedResults()
        @unSelectAll()
        @setMeta('current_page', 1)
        @setMeta('facets_changed', false)
        @setMeta('ignore_score', true)

      # Creates the Elastic Search Query parameters and serializes them
      requestData = @getRequestData()
      esJSONRequest = JSON.stringify(@getRequestData())
      # Uses POST to prevent result caching
      fetchESOptions =
        data: esJSONRequest
        type: 'POST'
        reset: true
        error: @errorHandler.bind(@)
      # Use options if specified by caller
      if not _.isUndefined(options) and _.isObject(options)
        _.extend(fetchESOptions, options)
      @loadFacetGroups() unless testMode or @isStreaming()

      if testMode or @getMeta('test_mode')
        return requestData

      # Call Backbone's fetch
      return Backbone.Collection.prototype.fetch.call(this, fetchESOptions)


    # ------------------------------------------------------------------------------------------------------------------
    # Parse/Fetch Facets Groups data
    # ------------------------------------------------------------------------------------------------------------------
    
    # Parses the facets groups aggregations data
    parseFacetsGroups: (facets_data)->
      if _.isUndefined(facets_data.aggregations)
        for facet_group_key, facet_group of @getFacetsGroups(true)
          facet_group.faceting_handler.parseESResults(facets_data.aggregations)

    # ------------------------------------------------------------------------------------------------------------------
    # Elastic Search Query structure
    # ------------------------------------------------------------------------------------------------------------------
    
    # given a list of chembl ids, it gives the request data to query for only those ids
    getRequestDataForChemblIDs: (page, pageSize, idsList) ->

      idPropertyName = @getMeta('id_column').comparator
      query =
        terms: {}
      query.terms[idPropertyName] = idsList
      return {
        size: pageSize,
        from: ((page - 1) * pageSize)
        query: query
      }

    getQueryForGeneratorList: ->

      idAttribute = @getMeta('model').ID_COLUMN.comparator
      generatorList = @getMeta('generator_items_list')

      idsList = (item[idAttribute] for item in generatorList)
      scores = {}
      if generatorList.length > 0
        for i in [0..generatorList.length-1]
          item = generatorList[i]
          if item.similarity?
            currentScore = parseFloat(item.similarity)
          else
            currentScore = ((generatorList.length - i) / generatorList.length) * 100
          scores[item[idAttribute]] = currentScore

      @setMeta('scores', scores)

      query_fgl = {
        terms: {}
      }
      query_fgl.terms[idAttribute] = idsList

      return {
        must_query:
          function_score:
            query: {}
            functions: [

             script_score:
               script:
                 lang: "painless",
                 params:
                   scores: scores
                 inline: "String mcid=doc['" + idAttribute + "'].value; "\
                   +"if(params.scores.containsKey(mcid)){return params.scores[mcid];} return 0;"
           ]
        filter_query:
          query_fgl
      }

    # generates an object with the data necessary to do the ES request
    # customPage: set a customPage if you want a page different than the one set as current
    # the same for customPageSize
    getRequestData: (customPage, customPageSize, request_facets=false, facets_first_call) ->
      # If facets are requested the facet filters are excluded from the query
      facets_filtered = true
      page = if customPage? then customPage else @getMeta('current_page')
      pageSize = if customPageSize? then customPageSize else @getMeta('page_size')

      # Base Elastic query
      es_query = {
        size: pageSize,
        from: ((page - 1) * pageSize)
        _source:
          includes: [ '*', '_metadata.*']
          excludes: [ '_metadata.related_targets.chembl_ids.*', '_metadata.related_compounds.chembl_ids.*']
        query:
          bool:
            must: []
            filter: []
      }
      @addSortingToQuery(es_query)
      @addHighlightsToQuery(es_query)

      # Custom query String query
      customQueryString = @getMeta('custom_query_string')
      generatorList = @getMeta('generator_items_list')
      if @getMeta('use_custom_query_string')
        es_query.query.bool.must = [{

          query_string:
            analyze_wildcard: true
            query: customQueryString
        }]
      # Normal Search query
      else if generatorList?
        glq = @getQueryForGeneratorList()
        es_query.query.bool.must.push glq.must_query
        es_query.query.bool.filter.push glq.filter_query
      else
        es_query.query.bool.must = @getMeta('searchESQuery')
      # Includes the selected facets filter
      if facets_filtered
        filter_query = @getFacetFilterQuery()
        if _.isArray(filter_query) and filter_query.length > 0
          es_query.query.bool.filter = _.union es_query.query.bool.filter, filter_query
        else if filter_query? and not _.isArray(filter_query)
          es_query.query.bool.filter.push filter_query

      if request_facets
        if not facets_first_call?
          throw "ERROR! If the request includes the facets the parameter facets_first_call should be defined!"
        facets_query = @getFacetsGroupsAggsQuery(facets_first_call)
        if facets_query
          es_query.aggs = facets_query

      stickyQuery = @getMeta('sticky_query')
      if stickyQuery?
        es_query.query.bool.must = [] unless es_query.query.bool.must?
        es_query.query.bool.must.push stickyQuery

      return es_query

    getAllColumns: ->

      defaultColumns = @getMeta('columns')
      contextualColumns = @getMeta('contextual_properties')
      return _.union(defaultColumns, contextualColumns)

    addHighlightsToQuery: (esQuery)->
      esQuery.highlight = {
        order: 'score'
        fragment_size: 150
        number_of_fragments: 3
        fragmenter: 'simple'
        pre_tags: [glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_OPEN_TAG]
        post_tags: [glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_CLOSE_TAG]
        type: 'fvh'
        fields:
          '*': {}
      }

    addSortingToQuery: (esQuery) ->
      sortList = []

      columns = @getAllColumns()
      for col in columns

        if col.is_sorting? and col.is_sorting !=0

          sortObj = {}
          if col.is_sorting == 1
            order = 'asc'
          if col.is_sorting == -1
            order = 'desc'

          sortObj[col.comparator] =
            order: order
          sortList.push sortObj

      esQuery.sort = sortList

    getFacetFilterQuery: () ->
      facet_queries = []
      faceting_handlers = []
      for facet_group_key, facet_group of @getFacetsGroups(true)
        faceting_handlers.push(facet_group.faceting_handler)
      facets_groups_query = glados.models.paginatedCollections.esSchema.FacetingHandler\
        .getAllFacetGroupsSelectedQuery(faceting_handlers)
      if facets_groups_query
        facet_queries.push facets_groups_query
      return facet_queries

    getFacetsGroupsAggsQuery: (facets_first_call)->
      non_selected_facets_groups = @getFacetsGroups(false)
      if non_selected_facets_groups
        aggs_query = {}
        for facet_group_key, facet_group of non_selected_facets_groups
          facet_group.faceting_handler.addQueryAggs(aggs_query, facets_first_call)
        return aggs_query

    __requestCurrentQuerySize: ()->
      es_url = @getURL()
      # Creates the Elastic Search Query parameters and serializes them
      esJSONRequestData = JSON.stringify(@getRequestData(1, 0,))
      # Uses POST to prevent result caching
      ajax_deferred = $.post(es_url, esJSONRequestData)
      return ajax_deferred

    # ------------------------------------------------------------------------------------------------------------------
    # Elastic Search Facets request
    # ------------------------------------------------------------------------------------------------------------------

    __requestFacetsGroupsData: (first_call)->
      es_url = @getURL()
      # Creates the Elastic Search Query parameters and serializes them
      # Includes the request for the faceting data
      esJSONRequestData = JSON.stringify(@getRequestData(1, 0, true, first_call))
      # Uses POST to prevent result caching
      ajax_deferred = $.post(es_url, esJSONRequestData)
      return ajax_deferred

    __parseFacetsGroupsData: (non_selected_facets_groups, es_data, first_call, resolve, reject, needs_second_call)->
      if not es_data? or not es_data.aggregations?
        console.error "ERROR! The aggregations data in the response is missing!"
        reject()
      for facet_group_key, facet_group of non_selected_facets_groups
        facet_group.faceting_handler.parseESResults(es_data.aggregations, first_call)
      if (first_call and not needs_second_call) or not first_call
        resolve()

    __loadFacetGroups: ()->
      promiseFunc = (resolve, reject)->
        non_selected_facets_groups = @getFacetsGroups(false)
        if _.keys(non_selected_facets_groups).length == 0
          resolve()
          return
        needs_second_call = false
        for group_key, facet_group of non_selected_facets_groups
          if facet_group.faceting_handler.needsSecondRequest()
            needs_second_call = true
        ajax_deferred = @__requestFacetsGroupsData(true)
        first_call = true
        done_callback = (es_data)->
          @__parseFacetsGroupsData(non_selected_facets_groups, es_data, first_call, resolve, reject, needs_second_call)
        fail_callback = ()->
          reject()
          setTimeout(@loadFacetGroups.bind(@), 1000)
        then_callback = ()->
          ajax_deferred_sc = @__requestFacetsGroupsData(false)
          first_call = false
          ajax_deferred_sc.done(done_callback.bind(@))
          ajax_deferred_sc.fail(fail_callback.bind(@))

        ajax_deferred.done(done_callback.bind(@))
        ajax_deferred.fail(fail_callback.bind(@))
        if needs_second_call
          ajax_deferred.then(then_callback.bind(@), null)
      runPromise = ()->
        @__last_facets_promise = new Promise(promiseFunc.bind(@))
        triggerEvent = ()->
          @trigger('facets-changed')
        @__last_facets_promise.then(triggerEvent.bind(@))

      if @__last_facets_promise?
        @__last_facets_promise.then(runPromise.bind(@))
      else
        runPromise.bind(@)()

    loadFacetGroups: ()->
      if not @__debouncedLoadFacetGroups?
        @__debouncedLoadFacetGroups = _.debounce(@__loadFacetGroups, 10)
      @__debouncedLoadFacetGroups()

    getFacetsGroups: (selected, onlyVisible=true)->

      if onlyVisible
        facetGroups = {}
        for facetGroupKey, facetGroup of @meta.facets_groups
          if facetGroup.show
            facetGroups[facetGroupKey] = facetGroup
      else
        facetGroups = @meta.facets_groups

      if not selected?
        return facetGroups
      else
        subFacetGroups = {}
        for facetGroupKey, facetGroup of facetGroups
          if selected == facetGroup.faceting_handler.hasSelection()
            subFacetGroups[facetGroupKey] = facetGroup
        return subFacetGroups

    clearAllFacetsSelections: ->

      for fGroupKey, fGroup of @getFacetsGroups(true, onlyVisible=false)
        fGroup.faceting_handler.clearSelections()

      @setMeta('facets_changed', true)
      @fetch()

    # builds the url to do the request
    getURL: ->
      glados.models.paginatedCollections.Settings.ES_BASE_URL + @getMeta('index') + '/_search'

    # ------------------------------------------------------------------------------------------------------------------
    # Items Selection
    # ------------------------------------------------------------------------------------------------------------------
    toggleSelectAll: ->
      @setMeta('all_items_selected', !@getMeta('all_items_selected'))
      @trigger('selection-changed')

    # ------------------------------------------------------------------------------------------------------------------
    # Streaming Mode
    # ------------------------------------------------------------------------------------------------------------------

    enableStreamingMode: ->
      @setMeta('streaming_mode', true)
      @loadFacetGroups()

    disableStreamingMode: ->
      delete @meta['streaming_mode']
      @loadFacetGroups()

    isStreaming: ->
      return @hasMeta('streaming_mode') and @getMeta('streaming_mode')

    shouldIgnoreContentChangeRequestWhileStreaming: ->
      return @isStreaming() and not @getMeta('page_changed')

    # ------------------------------------------------------------------------------------------------------------------
    # Metadata Handlers for query and pagination
    # ------------------------------------------------------------------------------------------------------------------

    removeMeta: (attr)->
      delete @meta[attr]

    setMeta: (attr, value) ->
      @meta[attr] = value
      @trigger('meta-changed')

    getMeta: (attr) ->
      return @meta[attr]

    hasMeta: (attr) ->
      return _.has(@meta, attr)

    # ------------------------------------------------------------------------------------------------------------------
    # Search functions
    # ------------------------------------------------------------------------------------------------------------------

    search: (jsonQuery)->
      final_callback = ()->
        @resetCache() unless not @getMeta('enable_collection_caching')
        @invalidateAllDownloadedResults()
        @unSelectAll()
        @clearAllResults()
        @clearAllFacetsSelections()
        @setPage(1, false)
        @fetch()
      final_callback = final_callback.bind(@)

      esKeyName = @getMeta 'key_name'
      curMinShouldMatch = 100
      fuzzy = false
      @setMeta('fuzzy-results', false)

      searchESQuery = if not jsonQuery? then {bool:{should:[],filter:[]}} else glados.models\
        .paginatedCollections.ESQueryBuilder.getESQueryForJsonQuery(jsonQuery, esKeyName, false, curMinShouldMatch+'%')
      @setMeta('searchESQuery', searchESQuery)
      ajax_deferred =  @__requestCurrentQuerySize()

      done_callback = (esData)->
        if jsonQuery? and esData.hits? and esData.hits.total? and esData.hits.total == 0 and curMinShouldMatch > 40
          curMinShouldMatch -= 30
          @setMeta(
            'searchESQuery',
            glados.models.paginatedCollections.ESQueryBuilder\
              .getESQueryForJsonQuery(jsonQuery, esKeyName, fuzzy, curMinShouldMatch+'%')
          )
          ajax_deferred =  @__requestCurrentQuerySize()
          ajax_deferred.done(done_callback)
        else if jsonQuery? and esData.hits? and esData.hits.total? and esData.hits.total == 0 and not fuzzy
          fuzzy = true
          @setMeta(
            'searchESQuery',
            glados.models.paginatedCollections.ESQueryBuilder\
              .getESQueryForJsonQuery(jsonQuery, esKeyName, fuzzy, curMinShouldMatch+'%')
          )
          ajax_deferred =  @__requestCurrentQuerySize()
          ajax_deferred.done(done_callback)
          @setMeta('fuzzy-results', true)
        else
          final_callback()

      done_callback = done_callback.bind(@)

      ajax_deferred.done(done_callback)


    # ------------------------------------------------------------------------------------------------------------------
    # Pagination functions
    # ------------------------------------------------------------------------------------------------------------------

    resetPageSize: (newPageSize) ->
      @setMeta('page_size', parseInt(newPageSize))
      @setPage(1)


    # Meta data values are:
    #  total_records
    #  current_page
    #  total_pages
    #  page_size
    #  records_in_page -- How many records are in the current page (useful if the last page has less than page_size)
    #  sorting data per column.
    #
    resetMeta: (totalRecords, max_score) ->
      max_score = if _.isNumber(max_score) then max_score else 0
      @setMeta('max_score', max_score)
      @setMeta('total_records', parseInt(totalRecords))
      if !@hasMeta('current_page')
        @setMeta('current_page', 1)
      if !@hasMeta('search_term')
        @setMeta('search_term', '')
      @setMeta('total_pages', Math.ceil(parseFloat(@getMeta('total_records')) / parseFloat(@getMeta('page_size'))))
      @calculateHowManyInCurrentPage()

    calculateHowManyInCurrentPage: ->
      current_page = @getMeta('current_page')
      total_pages = @getMeta('total_pages')
      total_records = @getMeta('total_records')
      page_size = @getMeta('page_size')

      if total_records == 0
        @setMeta('records_in_page', 0)
      else if current_page == total_pages and total_records % page_size != 0
        @setMeta('records_in_page', total_records % page_size)
      else
        @setMeta('records_in_page', @getMeta('page_size'))

    getCurrentPage: ->
      return @models

    setPage: (newPageNum, doFetch=true, testMode=false, customPageSize) ->
      newPageNum = parseInt(newPageNum)
      if doFetch and 1 <= newPageNum and newPageNum <= @getMeta('total_pages')
        @setMeta('current_page', newPageNum)
        if customPageSize?
          @setMeta('page_size', customPageSize)

        if @getMeta('enable_collection_caching')
          modelsInCache = @getObjectsInCacheFromPage(newPageNum)
          if modelsInCache?
            if modelsInCache.length > 0

              # this should be done in a better way
              if @getMeta('enable_substructure_highlighting') or @getMeta('enable_similarity_maps')
                for model in modelsInCache
                  model.set('show_similarity_map', @getMeta('show_similarity_maps'))
                  model.set('show_substructure_highlighting', @getMeta('show_substructure_highlighting'))

              @resetMeta(@getMeta('total_records'), @getMeta('total_records'))
              @reset(modelsInCache)
              @trigger('do-repaint')
              return

        @fetch(options=undefined, testMode)

     # tells if the current page is the las page
    currentlyOnLastPage: -> @getMeta('current_page') == @getMeta('total_pages')
    
    # ------------------------------------------------------------------------------------------------------------------
    # Sorting functions
    # ------------------------------------------------------------------------------------------------------------------

    sortCollection: (comparator) ->
      @resetCache() unless not @getMeta('enable_collection_caching')
      columns = @getAllColumns()
      @setupColSorting(columns, comparator)
      @invalidateAllDownloadedResults()
      @setMeta('current_page', 1)
      @setMeta('ignore_score', true)
      @fetch()

#TODO implement sorting

    resetSortData: ->
#TODO implement sorting


# sets the term to search in the collection
# when the collection is server side, the corresponding column and type are required.
# This is because the web services don't provide a search with OR
# for client side, it can be null, but for example for server side
# for chembl25, term will be 'chembl25', column will be 'molecule_chembl_id', and type will be 'text'
# the url will be generated taking into account this terms.
    setSearch: (term, column, type)->
#TODO Check if this is required

# from all the comparators, returns the one that is being used for sorting.
# if none is being used for sorting returns undefined
    getCurrentSortingComparator: () ->
#TODO implement sorting

    # ------------------------------------------------------------------------------------------------------------------
    # Download functions
    # ------------------------------------------------------------------------------------------------------------------
    DOWNLOADED_ITEMS_ARE_VALID: false
    DOWNLOAD_ERROR_STATE: false
    invalidateAllDownloadedResults: -> @DOWNLOADED_ITEMS_ARE_VALID = false
    clearAllResults: -> @allResults = undefined
    clearSelectedResults: -> @selectedResults = undefined

# this function iterates over all the pages and downloads all the results. This is independent of the pagination,
# but in the future it could be used to optimize the pagination after this has been called.
# it returns a list of deferreds which are the requests to the server, when the deferreds are done it means that
# I got everything. The idea is that if the results have been already loaded it immediately returns a resolved deferred
# without requesting again to the server.
# you can use a progress element to show the progress if you want.
    getAllResults: ($progressElement, askingForOnlySelected = false) ->

      if $progressElement?
        $progressElement.empty()

      thisCollection = @

      if askingForOnlySelected
        iNeedToGetEverything = not @thereAreExceptions()
        iNeedToGetEverythingExceptSome = @getMeta('all_items_selected') and @thereAreExceptions()
        iNeedToGetOnlySome = not @getMeta('all_items_selected') and @thereAreExceptions()
      else
        iNeedToGetEverything = true
        iNeedToGetEverythingExceptSome = false
        iNeedToGetOnlySome = false

      #if they want the selected ones only, and I already have them all just pick them from the list
      if askingForOnlySelected and @allResults? and @DOWNLOADED_ITEMS_ARE_VALID
        if not @thereAreExceptions()
          @selectedResults = @allResults
        else
          @selectedResults = _.filter(thisCollection.allResults, (item) ->
            itemID = glados.Utils.getNestedValue(item, thisCollection.getMeta('id_column').comparator)
            return thisCollection.itemIsSelected(itemID)
          )
        return [jQuery.Deferred().resolve()]

      # check if I already have all the results and they are valid
      if @allResults? and @DOWNLOADED_ITEMS_ARE_VALID
        return [jQuery.Deferred().resolve()]

      totalRecords = @getMeta('total_records')

      if not totalRecords?
        url = @getURL()
        requestData = JSON.stringify(thisCollection.getRequestData(1, 1))
        $.post(url, requestData).done((response) ->
          thisCollection.setMeta('total_records', response.hits.total)
          thisCollection.getAllResults($progressElement, askingForOnlySelected)
        )
        return

      pageSize = if totalRecords <= 100 then totalRecords else 100

      if totalRecords >= 10000 and not iNeedToGetOnlySome
        msg = 'It is still not supported to process 10000 items or more! (' + totalRecords + ' requested)'
        @DOWNLOAD_ERROR_STATE = true
#        errorModalID = 'error-' + parseInt(Math.random() * 1000)
#        $newModal = $(Handlebars.compile($('#Handlebars-Common-DownloadErrorModal').html())
#          modal_id: errorModalID
#          msg: msg
#        )
#        $('#BCK-GeneratedModalsContainer').append($newModal)
#        $newModal.modal()
#        $newModal.modal('open')
        return [jQuery.Deferred().reject(msg)]
      else if totalRecords == 0
        msg = 'There are no items to process'
        @setValidDownload()
        return [jQuery.Deferred().reject(msg)]

      if $progressElement?
        $progressElement.html Handlebars.compile($('#Handlebars-Common-DownloadColMessages0').html())
          percentage: '0'

      url = @getURL()

      #initialise the array in which all the items are going to be saved as they are received from the server
      if iNeedToGetOnlySome
        idsList = Object.keys(@getMeta('selection_exceptions'))
        @selectedResults = (undefined for num in [1..idsList.length])
        totalPages = Math.ceil(idsList.length / pageSize)
      else
        @allResults = (undefined for num in [1..totalRecords])
        @selectedResults = (undefined for num in [1..totalRecords])
        totalPages = Math.ceil(totalRecords / pageSize)

      itemsReceived = 0

      #this function knows how to get one page of results and add them in the corresponding positions in the all
      # items array
      getItemsFromPage = (currentPage) ->
        if iNeedToGetOnlySome
          data = JSON.stringify(thisCollection.getRequestDataForChemblIDs(currentPage, pageSize, idsList))
        else
          data = JSON.stringify(thisCollection.getRequestData(currentPage, pageSize))

        return $.post(url, data).done((response) ->

          #I know that I must be receiving currentPage.
          newItems = (item._source for item in response.hits.hits)
          # now I add them in the corresponding position in the items array
          startingPosition = (currentPage - 1) * pageSize

          for i in [0..(newItems.length - 1)]

            currentItem = newItems[i]

            if iNeedToGetEverythingExceptSome
              itemID = glados.Utils.getNestedValue(currentItem, thisCollection.getMeta('id_column').comparator)
              thisCollection.allResults[i + startingPosition] = currentItem
              if thisCollection.itemIsSelected(itemID)
                thisCollection.selectedResults[i + startingPosition] = currentItem

            else if iNeedToGetOnlySome
              thisCollection.selectedResults[i + startingPosition] = currentItem
            else if iNeedToGetEverything
              thisCollection.allResults[i + startingPosition] = currentItem

            itemsReceived++

          progress = parseInt((itemsReceived / totalRecords) * 100)

          if $progressElement? and (progress % 10) == 0
            $progressElement.html Handlebars.compile($('#Handlebars-Common-DownloadColMessages0').html())
              percentage: progress
        )

      deferreds = []
      # Now I request all pages, I accumulate all the deferreds in a list
      for page in [1..totalPages]
        deferreds.push(getItemsFromPage page)

      setValidDownload = $.proxy(@setValidDownload, @)
      $.when.apply($, deferreds).done -> setValidDownload()

      if iNeedToGetEverythingExceptSome
        f = $.proxy((->
          @removeHolesInAllResults
          @removeHolesInSelectedResults()
        ), @)
        $.when.apply($, deferreds).done -> f()

      if iNeedToGetEverything and askingForOnlySelected
        f = $.proxy(@makeSelectedSameAsAllResults, @)
        $.when.apply($, deferreds).done -> f()

      return deferreds

    setValidDownload: ->
      @DOWNLOADED_ITEMS_ARE_VALID = true
      @DOWNLOAD_ERROR_STATE = false
      @trigger(glados.Events.Collections.ALL_ITEMS_DOWNLOADED)
      # If the downloaded items are all of the collection use them as cache
      if @getMeta('enable_collection_caching') and not @getMeta('disable_cache_on_download')
        if @allResults?
          i = 0
          for obj in @allResults
            ModelType = @getMeta('model')
            model = new ModelType(obj)
            # trick to make sure parsed attributes such as img are created.
            model.set(model.parse(model.attributes))
            @addObjectToCache(model, i)
            i++

    removeHolesInAllResults: ->
      i = 0
      while i < @allResults.length
        currentItem = @allResults[i]
        if not currentItem?
          @allResults.splice(i, 1)
          i--
        i++

    removeHolesInSelectedResults: ->
      i = 0
      while i < @selectedResults.length
        currentItem = @selectedResults[i]
        if not currentItem?
          @selectedResults.splice(i, 1)
          i--
        i++

    makeSelectedSameAsAllResults: -> @selectedResults = @allResults

    getDownloadObject: (columns) ->
      downloadObj = []

      for item in @selectedResults

        row = {}
        for col in columns
          colLabel = col.name_to_show
          colValue = glados.Utils.getNestedValue(item, col.comparator)
          if col.parse_function?
            row[colLabel] = col.parse_function(colValue)
          else
            row[colLabel] = colValue

        downloadObj.push row

      return downloadObj

    # you can pass an Jquery elector to be used to report the status, 
    # see the template Handlebars-Common-DownloadColMessages0
    downloadAllItems: (format, columns=@getMeta('download_columns'), $progressElement) ->
      deferreds = @getAllResults($progressElement, true)

      thisCollection = @
      # Here I know that all the items have been obtainer, now I need to generate the file
      $.when.apply($, deferreds).done(->
        if $progressElement?
          $progressElement.html Handlebars.compile($('#Handlebars-Common-DownloadColMessages1').html())()

        downloadObject = thisCollection.getDownloadObject.call(thisCollection, columns)

        if format == glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV']
          DownloadModelOrCollectionExt.downloadCSV('results.csv', null, downloadObject)
          # erase progress element contents after some milliseconds
          setTimeout((()-> $progressElement.html ''), 1000)
        else if format == glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']
          DownloadModelOrCollectionExt.downloadCSV('results.tsv', null, downloadObject, isTabSeparated=true)
          # erase progress element contents after some milliseconds
          setTimeout((()-> $progressElement.html ''), 1000)
        else if format == glados.Settings.DEFAULT_FILE_FORMAT_NAMES['SDF']
          idsList = (item.molecule_chembl_id for item in thisCollection.selectedResults)
          # here I have the IDs, I have to request them to the server as SDF
          DownloadModelOrCollectionExt.generateSDFFromChemblIDs idsList, $progressElement
      ).fail((msg) ->
        if $progressElement?
          $progressElement.html Handlebars.compile($('#Handlebars-Common-CollectionErrorMsg').html())
            msg: msg
      )
  ,
    HIGHLIGHT_SUFFIXES_TO_REMOVE: [
      'eng_analyzed', 'ws_analyzed', 'std_analyzed', 'alphanumeric_lowercase_keyword', /\.\d*$/
    ]
    HIGHLIGHT_OPEN_TAG: '<em class="glados-result-highlight">'
    HIGHLIGHT_CLOSE_TAG: '</em>'
    HIGHLIGHT_MAX_WORD_LENGTH: 10

glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_OPEN_TAG_REGEX_ESCAPED = \
  glados.Utils.escapeRegExp glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_OPEN_TAG
glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_CLOSE_TAG_REGEX_ESCAPED = \
  glados.Utils.escapeRegExp glados.models.paginatedCollections.ESPaginatedQueryCollection.HIGHLIGHT_CLOSE_TAG