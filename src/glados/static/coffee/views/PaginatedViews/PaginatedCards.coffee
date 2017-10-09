glados.useNameSpace 'glados.views.PaginatedViews',
  PaginatedCards:

    initAvailablePageSizes: ->
      @AVAILABLE_PAGE_SIZES = [6, 12, 24, 48, 96, 192]

      defaultPageSize = @collection.getMeta('default_page_size')
      if defaultPageSize?
        @currentPageSize = defaultPageSize
      else
        @currentPageSize = @AVAILABLE_PAGE_SIZES[2]

    #-------------------------------------------------------------------------------------------------------------------
    # Zoom
    #-------------------------------------------------------------------------------------------------------------------
    CARD_SIZE_TO_MIN_PAGE_SIZE:
      12: 6
      6: 6
      4: 12
      3: 24
      2: 96
      1: 192

    finishZoom: (minPageSize) ->

      if @currentPageSize < minPageSize
        @requestPageSizeInCollection(minPageSize)
      else
        @render()

    renderViewState: ->

      isDefaultZoom = @mustDisableReset()
      mustComplicate = @collection.getMeta('complicate_cards_view')
      @isComplicated = isDefaultZoom and mustComplicate

      @clearContentContainer()

      if @hasStructureHighlightingEnabled() or @hasSimilarityMapsEnabled()
        @cleanUpDeferredViewsContainer()

      if @hasCustomElementView()
        @cleanUpCustomItemViewsContainer()

      @fillTemplates()

      @fillSelectAllContainer() unless @disableItemsSelection

      if @isCardsZoomEnabled()
        @fillZoomContainer()

      if @hasStructureHighlightingEnabled() or @hasSimilarityMapsEnabled()
        @renderSpecialStructuresToggler()

      @fillPaginators()
      @fillPageSizeSelectors()
      @activateSelectors()
      @showPaginatedViewContent()

      if @collection.getMeta('fuzzy-results')? and @collection.getMeta('fuzzy-results') == true
        @showSuggestedLabel()
      else
        @hideSuggestedLabel()

      glados.views.PaginatedViews.PaginatedViewBase.renderViewState.call(@)

    sleepView: ->

      if @hasCustomElementView()
        @sleepCustomElementviews()

      glados.views.PaginatedViews.PaginatedViewBase.sleepView.call(@)

    # ------------------------------------------------------------------------------------------------------------------
    # Columns initalisation
    # ------------------------------------------------------------------------------------------------------------------
    getDefaultColumns: -> @collection.getMeta('columns_description').Cards.Default
    getAdditionalColumns: -> @collection.getMeta('columns_description').Cards.Additional
    getVisibleColumns: ->
      if @isComplicated
        _.filter(@collection.getMeta('complicate_card_columns'), -> true)
      else
        glados.views.PaginatedViews.PaginatedViewBase.getVisibleColumns.call(@)