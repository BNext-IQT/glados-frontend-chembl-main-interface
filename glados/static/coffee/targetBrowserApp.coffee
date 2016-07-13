class TargetBrowserApp

  ### *
    * Initializes a target hierarchy tree
    * return {TargetHierarchyTree}
  ###
  @initTargetHierarchyTree = ->
    targetTree = new TargetHierarchyTree

    # TODO: set up the correct url
    targetTree.url = 'static/data/gene_ontology_tree.json'

    return targetTree


  # This initialises the view of the tree as a list
  @initBrowserAsList = (model, top_level_elem) ->

    asListView = new BrowseTargetAsListView
      model: model
      el: top_level_elem

    return asListView

  # This initialises the view of the tree as a circles
  @initBrowserAsCircles = (model, top_level_elem) ->

    asCirclesView = new BrowseTargetAsCirclesView
      model: model
      el: top_level_elem

    return asCirclesView

  # This initialises the view that takes care of the
  # controls and creates the other 2 views
  @initBrowserMain = (model, top_level_elem) ->

    mainView = new BrowseTargetMainView
      model: model
      el: top_level_elem

    return mainView