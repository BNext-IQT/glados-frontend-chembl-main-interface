# this view is in charge of handling the selection of the different views in the advanced search
glados.useNameSpace 'glados.views.SearchResults',
  AdvancedSearchView: Backbone.View.extend

    initialize: ->

      console.log('INIT ADVANCED SEARCH VIEW!')
      @initDefaultTab()

    initDefaultTab: ->

      @initMarvinSketcher()

    initMarvinSketcher: ->

