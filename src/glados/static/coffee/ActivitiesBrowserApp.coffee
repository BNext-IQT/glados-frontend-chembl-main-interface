class ActivitiesBrowserApp

  @init = ->

    filter = URLProcessor.getFilter()
    actsList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESActivitiesList(filter)

    new glados.views.Browsers.BrowserMenuView
      collection: actsList
      el: $('.BCK-BrowserContainer')
      standalone_mode: true

    new glados.views.Browsers.BrowserFacetView
      collection: actsList
      standalone_mode: true

    actsList.fetch()

  @initMatrixCellMiniReportCard: ($containerElem, d) ->
    console.log 'INITIALIZING MINI REP CARD: ', $containerElem, d

    summary = new glados.models.Activity.CompoundTargetActivitySummary()
    new MiniReportCardView
      el: $containerElem
      model: summary
      entity: Activity