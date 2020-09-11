# this view is in charge of handling the selection of the different views in the advanced search
glados.useNameSpace 'glados.views.SearchResults',
  AdvancedSearchView: Backbone.View.extend

    TABS_IDENTIFIERS:
      SEARCH_BY_IDS: 'search_by_ids'
      SEARCH_BY_CHEMICAL_STRUCTURE: 'chemical_structure'
      SEARCH_BY_BIOLOGICAL_SEQUENCE: 'biological_sequence'

    initialize: ->
      console.log('INIT ADVANCED SEARCH VIEW!')
      @initDefaultTab()

    events:
      'click .BCK-select-tab': 'selectTab'

    initDefaultTab: ->
      @openChemicalStructureSearchTab()

    openChemicalStructureSearchTab: ->
      @unselectAllTabs()
      @selectTab(@TABS_IDENTIFIERS.SEARCH_BY_CHEMICAL_STRUCTURE)
      @hideAllTabs()

      $searchTypeContainer = $(@el).find('.BCK-Structure-Search')
      $searchTypeContainer.show()

      if not @marvinEditor?
        @marvinEditor = new MarvinSketcherView
          el: $searchTypeContainer

    openBiologicalSequenceSearch: ->
      @unselectAllTabs()
      @selectTab(@TABS_IDENTIFIERS.SEARCH_BY_BIOLOGICAL_SEQUENCE)
      @hideAllTabs()

      $searchTypeContainer = $(@el).find('.BCK-BiologicalSequence-Search')
      $searchTypeContainer.show()

    openByIDsSearch: ->
      @unselectAllTabs()
      @selectTab(@TABS_IDENTIFIERS.SEARCH_BY_IDS)
      @hideAllTabs()

      $searchTypeContainer = $(@el).find('.BCK-ByIDs-Search')
      $searchTypeContainer.show()

    selectTab: (event) ->
      console.log('SELECT TAB')
      $clickedElem = $(event.currentTarget)
      desiredViewType = $clickedElem.attr('data-tab')
      console.log('desiredViewType: ', desiredViewType)

      if desiredViewType == @TABS_IDENTIFIERS.SEARCH_BY_IDS
        console.log('OPEN SEARCH BY IDS')
        @openByIDsSearch()

      else if desiredViewType == @TABS_IDENTIFIERS.SEARCH_BY_CHEMICAL_STRUCTURE
        console.log('SEARCH_BY_CHEMICAL_STRUCTURE')
        @openChemicalStructureSearchTab()
      else if desiredViewType == @TABS_IDENTIFIERS.SEARCH_BY_BIOLOGICAL_SEQUENCE
        console.log('SEARCH BY biological_sequence')
        @openBiologicalSequenceSearch()

    hideAllTabs: ->
      $allTabs = $(@el).find('.BCK-tab-content')
      $allTabs.hide()

    unselectAllTabs: ->
      $allTabsSelector = $(@el).find('.BCK-select-tab')
      $allTabsSelector.removeClass('selected')

    selectTab: (tab_id) ->

      if tab_id == @TABS_IDENTIFIERS.SEARCH_BY_IDS
        $tabSelector = $(@el).find('.BCK-select-tab[data-tab="search_by_ids"]')
        $tabSelector.addClass('selected')
      else if tab_id == @TABS_IDENTIFIERS.SEARCH_BY_CHEMICAL_STRUCTURE
        $tabSelector = $(@el).find('.BCK-select-tab[data-tab="biological_sequence"]')
        $tabSelector.addClass('selected')
      else if tab_id == @TABS_IDENTIFIERS.SEARCH_BY_BIOLOGICAL_SEQUENCE
        $tabSelector = $(@el).find('.BCK-select-tab[data-tab="chemical_structure"]')
        $tabSelector.addClass('selected')

