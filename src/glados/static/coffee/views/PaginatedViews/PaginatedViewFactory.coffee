glados.useNameSpace 'glados.views.PaginatedViews',
  PaginatedViewFactory:
    CARDS_TYPE: 'CARDS_TYPE'
    CAROUSEL_TYPE: 'CAROUSEL_TYPE'
    INFINITE_TYPE: 'INFINITE_TYPE'
    TABLE_TYPE: 'TABLE_TYPE'

    Cards: Backbone.View\
      .extend(glados.views.PaginatedViews.PaginatedViewBase)\
      .extend(glados.views.PaginatedViews.DeferredViewsFunctions)\
      .extend(glados.views.PaginatedViews.CardZoomFunctions)\
      .extend(glados.views.PaginatedViews.ItemViewsFunctions)\
      .extend(glados.views.PaginatedViews.PaginationFunctions)\
      .extend(glados.views.PaginatedViews.TooltipFunctions)\
      .extend(glados.views.PaginatedViews.SelectionFunctions)\
      .extend(glados.views.PaginatedViews.PaginatedCards)

    Carousel: Backbone.View\
      .extend(glados.views.PaginatedViews.PaginatedViewBase)\
      .extend(glados.views.PaginatedViews.DeferredViewsFunctions)\
      .extend(glados.views.PaginatedViews.CardZoomFunctions)\
      .extend(glados.views.PaginatedViews.ItemViewsFunctions)\
      .extend(glados.views.PaginatedViews.PaginationFunctions)\
      .extend(glados.views.PaginatedViews.TooltipFunctions)\
      .extend(glados.views.PaginatedViews.SelectionFunctions)\
      .extend(glados.views.PaginatedViews.Carousel)

    Infinite: Backbone.View\
      .extend(glados.views.PaginatedViews.PaginatedViewBase)\
      .extend(glados.views.PaginatedViews.DeferredViewsFunctions)\
      .extend(glados.views.PaginatedViews.CardZoomFunctions)\
      .extend(glados.views.PaginatedViews.ItemViewsFunctions)\
      .extend(glados.views.PaginatedViews.PaginationFunctions)\
      .extend(glados.views.PaginatedViews.TooltipFunctions)\
      .extend(glados.views.PaginatedViews.SelectionFunctions)\
      .extend(glados.views.PaginatedViews.InfiniteCards)

    Table: Backbone.View\
      .extend(glados.views.PaginatedViews.PaginatedViewBase)\
      .extend(glados.views.PaginatedViews.DeferredViewsFunctions)\
      .extend(glados.views.PaginatedViews.CardZoomFunctions)\
      .extend(glados.views.PaginatedViews.ItemViewsFunctions)\
      .extend(glados.views.PaginatedViews.PaginationFunctions)\
      .extend(glados.views.PaginatedViews.TooltipFunctions)\
      .extend(glados.views.PaginatedViews.SelectionFunctions)\
      .extend(glados.views.PaginatedViews.PaginatedTable)

    getNewCardsPaginatedView: (collection, el, customRenderEvents, config)->

      View = glados.views.PaginatedViews.PaginatedViewFactory.Cards

      return new View
        collection: collection
        el: el
        type: glados.views.PaginatedViews.PaginatedViewFactory.CARDS_TYPE
        custom_render_evts: customRenderEvents
        config: config

    initPaginatedCardsEmbedded: (initFunctionParams) ->

      encodedState = initFunctionParams.state
      state = JSON.parse(atob(encodedState))
      list = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESResultsListFromState(state)

      viewConfig =
        embedded: true
      glados.views.PaginatedViews.PaginatedViewFactory.getNewCardsPaginatedView(list, $('#BCK-embedded-content'),
        viewConfig)

      list.fetch()

    getNewCardsCarouselView: (collection, el, customRenderEvents, config)->

      View = glados.views.PaginatedViews.PaginatedViewFactory.Carousel

      return new View
        collection: collection
        el: el
        type: glados.views.PaginatedViews.PaginatedViewFactory.CAROUSEL_TYPE
        custom_render_evts: customRenderEvents
        config: config

    getNewInfinitePaginatedView: (collection, el, customRenderEvents)->

      View = glados.views.PaginatedViews.PaginatedViewFactory.Infinite

      return new View
        collection: collection
        el: el
        type: glados.views.PaginatedViews.PaginatedViewFactory.INFINITE_TYPE
        custom_render_evts: customRenderEvents

    getNewTablePaginatedView: (collection, el, customRenderEvents,
      disableColumnsSelection=false, disableItemSelection=true)->

      View = glados.views.PaginatedViews.PaginatedViewFactory.Table

      return new View
        collection: collection
        el: el
        type: glados.views.PaginatedViews.PaginatedViewFactory.TABLE_TYPE
        custom_render_evts: customRenderEvents
        disable_columns_selection: disableColumnsSelection
        disable_items_selection: disableItemSelection


    getTypeConstructor: (pagViewType)->
      viewClass = undefined
      if pagViewType == glados.views.PaginatedViews.PaginatedViewFactory.CARDS_TYPE
        viewClass = glados.views.PaginatedViews.PaginatedViewFactory.Cards
      else if pagViewType == glados.views.PaginatedViews.PaginatedViewFactory.TABLE_TYPE
        viewClass = glados.views.PaginatedViews.PaginatedViewFactory.Table
      else if pagViewType == glados.views.PaginatedViews.PaginatedViewFactory.INFINITE_TYPE
        viewClass = glados.views.PaginatedViews.PaginatedViewFactory.Infinite

      tmp_constructor = ->
        arguments[0].type = pagViewType
        viewClass.apply(@, arguments)

      tmp_constructor.prototype = viewClass.prototype

      return tmp_constructor

    getCardsConstructor: ->
      return glados.views.PaginatedViews.PaginatedViewFactory\
        .getTypeConstructor(glados.views.PaginatedViews.PaginatedViewFactory.CARDS_TYPE)

    getTableConstructor: ->
      return glados.views.PaginatedViews.PaginatedViewFactory\
        .getTypeConstructor(glados.views.PaginatedViews.PaginatedViewFactory.TABLE_TYPE)

    getInfiniteConstructor: ->
      return glados.views.PaginatedViews.PaginatedViewFactory\
        .getTypeConstructor(glados.views.PaginatedViews.PaginatedViewFactory.INFINITE_TYPE)
