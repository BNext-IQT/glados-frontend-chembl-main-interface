glados.useNameSpace 'glados.models.Aggregations',
  Aggregation: Backbone.Model.extend

    #-------------------------------------------------------------------------------------------------------------------
    # Initialisation
    #-------------------------------------------------------------------------------------------------------------------
    initialize: ->
      @url = @get('index_url')
      @set('state', glados.models.Aggregations.Aggregation.States.INITIAL_STATE)
      @loadQuery()

    loadQuery: ->
      queryConfig = @get('query_config')
      if queryConfig.type == glados.models.Aggregations.Aggregation.QueryTypes.MULTIMATCH
        query =
          multi_match:
            query: @get(queryConfig.queryValueField)
            fields: queryConfig.fields
        @set('query', query)
      else if queryConfig.type == glados.models.Aggregations.Aggregation.QueryTypes.QUERY_STRING
        templateValues = {}
        templateData = queryConfig.template_data

        for propKey, propName of templateData
          templateValues[propKey] = @get(propName)

        queryStringTemplate = queryConfig.query_string_template
        queryString = Handlebars.compile(queryStringTemplate)(templateValues)

        query =
          query_string:
            query: queryString
            analyze_wildcard: true
        @set('query', query)

    getAggregationConfig: (aggName) ->

      aggsConfig = @get('aggs_config')
      return aggsConfig.aggs[aggName]

    #-------------------------------------------------------------------------------------------------------------------
    # Changing configuration
    #-------------------------------------------------------------------------------------------------------------------
    cleanUpRangeAggConfig: (aggConfig) ->

      aggConfig.max_bin_size = null
      aggConfig.min_bin_size = null
      aggConfig.max_value = null
      aggConfig.min_value = null
      aggConfig.bin_size = null
      aggConfig.intervals_set_by_bin_size = null

    changeFieldForAggregation: (aggName, newField) ->

      aggConfig = @getAggregationConfig(aggName)
      if aggConfig.type == glados.models.Aggregations.Aggregation.AggTypes.RANGE
        @cleanUpRangeAggConfig(aggConfig)

      aggConfig.field = newField

      @fetch() unless @get('test_mode')

    changeNumColumnsForAggregation: (aggName, newNumColumns) ->

      aggConfig = @getAggregationConfig(aggName)
      if aggConfig.type == glados.models.Aggregations.Aggregation.AggTypes.RANGE
        @cleanUpRangeAggConfig(aggConfig)

      aggConfig.num_columns = newNumColumns
      @fetch() unless @get('test_mode')

    changeBinSizeForAggregation: (aggName, newBinSize) ->

      aggConfig = @getAggregationConfig(aggName)
      if aggConfig.type == glados.models.Aggregations.Aggregation.AggTypes.RANGE
        @cleanUpRangeAggConfig(aggConfig)

      aggConfig.bin_size = newBinSize
      aggConfig.intervals_set_by_bin_size = true

      @fetch() unless @get('test_mode')
    #-------------------------------------------------------------------------------------------------------------------
    # Fetching
    #-------------------------------------------------------------------------------------------------------------------
    needsMinAndMax: ->

      aggsConfig = @get('aggs_config')
      aggs = aggsConfig.aggs
      for aggKey, aggDescription of aggs
        if aggDescription.type == glados.models.Aggregations.Aggregation.AggTypes.RANGE
          return true
      return false

    fetch: ->

      $progressElem = @get('progress_elem')
      state = @get('state')

      if @needsMinAndMax() and\
      (state == glados.models.Aggregations.Aggregation.States.INITIAL_STATE\
      or state == glados.models.Aggregations.Aggregation.States.NO_DATA_FOUND_STATE)
        if $progressElem?
          $progressElem.html 'Loading minimun and maximum values...'

        @set('state', glados.models.Aggregations.Aggregation.States.LOADING_MIN_MAX)
        @fetchMinMax()
        return

      if $progressElem?
        $progressElem.html 'Fetching Data...'
      @set('state', glados.models.Aggregations.Aggregation.States.LOADING_BUCKETS)

      esJSONRequest = JSON.stringify(@getRequestData())

      fetchESOptions =
        url: @url
        data: esJSONRequest
        type: 'POST'
        reset: true

      thisModel = @
      $.ajax(fetchESOptions).done((data) ->
        if $progressElem?
          $progressElem.html ''

        if data.hits.total == 0
          thisModel.set
            'state': glados.models.Aggregations.Aggregation.States.NO_DATA_FOUND_STATE
        else
          thisModel.set
            'bucket_data': thisModel.parse(data)
            'state': glados.models.Aggregations.Aggregation.States.INITIAL_STATE


      ).fail( -> glados.Utils.ErrorMessages.showLoadingErrorMessageGen($progressElem))

    fetchMinMax: ->

      $progressElem = @get('progress_elem')
      esJSONRequest = JSON.stringify(@getRequestMinMaxData())

      fetchESOptions =
        url: @url
        data: esJSONRequest
        type: 'POST'
        reset: true

      thisModel = @
      $.ajax(fetchESOptions).done((data) ->

        thisModel.set('aggs_config', thisModel.parseMinMax(data))

        if thisModel.get('state') == glados.models.Aggregations.Aggregation.States.NO_DATA_FOUND_STATE
          $progressElem.html '' unless not $progressElem?
          return

        thisModel.set('state', glados.models.Aggregations.Aggregation.States.LOADING_BUCKETS)
        thisModel.fetch()

      ).fail( -> glados.Utils.ErrorMessages.showLoadingErrorMessageGen($progressElem))


    #-------------------------------------------------------------------------------------------------------------------
    # Parsing
    #-------------------------------------------------------------------------------------------------------------------
    parseMinMax: (data) ->

      if data.hits.total == 0
        @set('state', glados.models.Aggregations.Aggregation.States.NO_DATA_FOUND_STATE)
        return @get('aggs_config')

      aggsConfig = @get('aggs_config')
      receivedAggsInfo = data.aggregations

      aggs = aggsConfig.aggs
      for aggKey, aggDescription of aggs

        if aggDescription.type == glados.models.Aggregations.Aggregation.AggTypes.RANGE
          minAggName = @getMinAggName(aggKey)
          currentAggReceivedMin = receivedAggsInfo[minAggName].value
          aggDescription.min_value = currentAggReceivedMin

          maxAggName = @getMaxAggName(aggKey)
          currentAggReceivedMax = receivedAggsInfo[maxAggName].value
          aggDescription.max_value = currentAggReceivedMax

          minColumns = aggDescription.min_columns
          maxColumns = aggDescription.max_columns

          maxBinSize = glados.Utils.Buckets.getIntervalSize(currentAggReceivedMax, currentAggReceivedMin, minColumns)
          minBinSize = glados.Utils.Buckets.getIntervalSize(currentAggReceivedMax, currentAggReceivedMin, maxColumns)

          aggDescription.min_bin_size = minBinSize
          aggDescription.max_bin_size = maxBinSize

      return aggsConfig


    parse: (data) ->

      bucketsData = {}
      aggsConfig = @get('aggs_config')
      receivedAggsInfo = data.aggregations

      aggs = aggsConfig.aggs
      for aggKey, aggDescription of aggs

        # ---------------------------------------------------------------------
        # Parsing by type
        # ---------------------------------------------------------------------
        if aggDescription.type == glados.models.Aggregations.Aggregation.AggTypes.RANGE

          currentBuckets = receivedAggsInfo[aggKey].buckets
          bucketsList = glados.Utils.Buckets.getBucketsList(currentBuckets)
          currentNumCols = bucketsList.length

          currentMinValue = aggDescription.min_value
          currentMaxValue = aggDescription.max_value

          intervalSize = glados.Utils.Buckets.getIntervalSize(currentMaxValue, currentMinValue, currentNumCols)

          @parseBucketsLink(aggDescription, bucketsList)

          bucketsData[aggKey] =
            buckets: bucketsList
            num_columns: currentNumCols
            bin_size: intervalSize
            min_bin_size: aggDescription.min_bin_size
            max_bin_size: aggDescription.max_bin_size

        else if aggDescription.type == glados.models.Aggregations.Aggregation.AggTypes.TERMS

          currentBuckets = receivedAggsInfo[aggKey].buckets
          currentNumCols = currentBuckets.length

          @parseBucketsLink(aggDescription, currentBuckets)

          bucketsData[aggKey] =
            buckets: currentBuckets
            num_columns: currentNumCols
            buckets_index: _.indexBy(currentBuckets, 'key')

      return bucketsData

    parseBucketsLink: (aggDescription, bucketsList) ->

      linksDescription = aggDescription.bucket_links

      if linksDescription?
        templateDataDesc =  linksDescription.template_data
        templateDataFunc = linksDescription.template_data_func
        template = linksDescription.bucket_filter_template
        linkGenerator = linksDescription.link_generator
        generateFilter = Handlebars.compile(template)
        for bucket in bucketsList
          @setLinkForBucket(generateFilter, templateDataDesc, bucket, linkGenerator)

    getMergedLink: (bucketsToMerge, aggName) ->

      currentAggConfig = @get('aggs_config').aggs[aggName]
      linksDescription = currentAggConfig.bucket_links
      templateDataDesc =  linksDescription.template_data
      template = linksDescription.bucket_filter_template
      linkGenerator = linksDescription.link_generator
      generateFilter = Handlebars.compile(template)

      @setLinkForBucket(generateFilter, templateDataDesc, undefined , linkGenerator, bucketsToMerge)

    setLinkForBucket: (compiledTemplate, templateDataDesc, bucket, linkGenerator, bucketsToMerge) ->

      if bucketsToMerge?
        bucket = bucketsToMerge[0]
        restOfBuckets = bucketsToMerge[1..bucketsToMerge.length-1]

      templateValues = {}
      for propKey, propExp of templateDataDesc

        if propExp.startsWith('BUCKET')
          propName = propExp.split('.')[1]
          value = bucket[propName]
        else if propExp.startsWith('EXTRA_BUCKETS') and bucketsToMerge?
          propName = propExp.split('.')[1]
          value = (b.key for b in restOfBuckets)
        else
          value = @get(propExp)

        templateValues[propKey] = value

      bucket.link = linkGenerator(compiledTemplate(templateValues))

    #-------------------------------------------------------------------------------------------------------------------
    # Request Data
    #-------------------------------------------------------------------------------------------------------------------
    # Checks only first level for now
    # if there is no need to get min and max data, it returns undefined
    getRequestMinMaxData: ->

      aggsData = {}
      aggsConfig = @get('aggs_config')

      aggs = aggsConfig.aggs
      for aggKey, aggDescription of aggs
        if aggDescription.type == glados.models.Aggregations.Aggregation.AggTypes.RANGE
          minAggName = @getMinAggName(aggKey)
          aggsData[minAggName] =
            min:
              field: aggDescription.field

          maxAggName = @getMaxAggName(aggKey)
          aggsData[maxAggName] =
            max:
              field: aggDescription.field

      queryData = @get('query')

      return {
        size: 0
        query: queryData
        aggs: aggsData

      }


    getMinAggName: (aggKey) -> aggKey + '_min'
    getMaxAggName: (aggKey) -> aggKey + '_max'

    getRequestData: ->

      aggsData = {}
      aggsConfig = @get('aggs_config')

      aggs = aggsConfig.aggs
      for aggKey, aggDescription of aggs
        if aggDescription.type == glados.models.Aggregations.Aggregation.AggTypes.RANGE

          minValue = aggDescription.min_value
          maxValue = aggDescription.max_value

          if aggDescription.intervals_set_by_bin_size
            interval = aggDescription.bin_size
            numCols = Math.ceil(Math.abs(maxValue - minValue) / interval)
          else
            numCols = aggDescription.num_columns

          ranges = glados.Utils.Buckets.getElasticRanges(minValue, maxValue, numCols)

          aggsData[aggKey] =
            range:
              field: aggDescription.field
              ranges: ranges
              keyed: true

        else if aggDescription.type == glados.models.Aggregations.Aggregation.AggTypes.TERMS

          aggsData[aggKey] =
            terms:
              field: aggDescription.field
              size: aggDescription.size
              order:
                _count: 'desc'

      queryData = @get('query')

      return {
        size: 0
        query: queryData
        aggs: aggsData
      }


glados.models.Aggregations.Aggregation.COMPOUND_INDEX_URL = glados.models.paginatedCollections.Settings.ES_BASE_URL\
+ '/chembl_molecule/_search'

glados.models.Aggregations.Aggregation.ACTIVITY_INDEX_URL = glados.models.paginatedCollections.Settings.ES_BASE_URL\
+ '/chembl_activity/_search'

glados.models.Aggregations.Aggregation.TARGET_INDEX_URL = glados.models.paginatedCollections.Settings.ES_BASE_URL\
+ '/chembl_target/_search'

glados.models.Aggregations.Aggregation.ASSAY_INDEX_URL = glados.models.paginatedCollections.Settings.ES_BASE_URL\
+ '/chembl_assay/_search'

glados.models.Aggregations.Aggregation.DOCUMENT_INDEX_URL = glados.models.paginatedCollections.Settings.ES_BASE_URL\
+ '/chembl_document/_search'

glados.models.Aggregations.Aggregation.States =
  INITIAL_STATE: 'INITIAL_STATE'
  LOADING_MIN_MAX: 'LOADING_MIN_MAX'
  LOADING_BUCKETS: 'LOADING_BUCKETS'
  NO_DATA_FOUND_STATE: 'NO_DATA_FOUND_STATE'

glados.models.Aggregations.Aggregation.QueryTypes =
   MULTIMATCH: 'MULTIMATCH'
   QUERY_STRING: 'QUERY_STRING'

glados.models.Aggregations.Aggregation.AggTypes =
   RANGE: 'RANGE'
   TERMS: 'TERMS'