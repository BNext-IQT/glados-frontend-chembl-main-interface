# This is a base object for the paginated tables, extend a view in backbone with this object
# to get the functionality for handling the pagination.
# this way allows to easily handle multiple inheritance in the models.
glados.useNameSpace 'glados.views.PaginatedViews',
  PaginatedView: Backbone.View.extend
  
    # ------------------------------------------------------------------------------------------------------------------
    # Initialisation
    # ------------------------------------------------------------------------------------------------------------------
  
    initialize: () ->
      # @collection - must be provided in the constructor call
      @type = arguments[0].type
  
      @collection.on 'reset do-repaint sort', @render, @
      @collection.on 'selection-changed', @selectionChangedHandler, @
  
      @render()
  
    isCards: ()->
      return @type == glados.views.PaginatedViews.PaginatedView.CARDS_TYPE
  
    isCarousel: ()->
      return @type == glados.views.PaginatedViews.PaginatedView.CAROUSEL_TYPE
  
    isInfinite: ()->
      return @type == glados.views.PaginatedViews.PaginatedView.INFINITE_TYPE
  
    isTable: ()->
      return @type == glados.views.PaginatedViews.PaginatedView.TABLE_TYPE
  
    # ------------------------------------------------------------------------------------------------------------------
    # events 
    # ------------------------------------------------------------------------------------------------------------------
  
    events:
      'click .page-selector': 'getPageEvent'
      'change .change-page-size': 'changePageSize'
      'click .sort': 'sortCollection'
      'input .search': 'setSearch'
      'change select.select-search' : 'setSearch'
      'change .select-sort': 'sortCollectionFormSelect'
      'click .btn-sort-direction': 'changeSortOrderInf'
      'click .BCK-show-hide-column': 'showHideColumn'
      'click .BCK-toggle-select-all': 'toggleSelectAll'
  
  
    # ------------------------------------------------------------------------------------------------------------------
    # Selection
    # ------------------------------------------------------------------------------------------------------------------
    toggleSelectAll: ->
      @collection.toggleSelectAll()
  
    selectionChangedHandler: (elemId)->
      return
  
    # ------------------------------------------------------------------------------------------------------------------
    # Render
    # ------------------------------------------------------------------------------------------------------------------
  
    render: ->
  
      @clearContentContainer()
      @fillTemplates()
      @fillSelectAllContainer()
      @fillPaginators()
      @fillPageSelectors()
      @activateSelectors()
      @showPaginatedViewContent()
      @initialiseColumnsModal()
  
  
  
  
    # ------------------------------------------------------------------------------------------------------------------
    # Fill templates
    # ------------------------------------------------------------------------------------------------------------------
  
    clearTemplates: ->
      $(@el).find('.BCK-items-container').empty()
  
    # fills a template with the contents of the collection's current page
    # it handle the case when the items are shown as list, table, or infinite browser
    fillTemplates: ->
  
      $elem = $(@el).find('.BCK-items-container')
  
      if @collection.length > 0
        for i in [0..$elem.length - 1]
          @sendDataToTemplate $($elem[i])
        @showFooterContainer()
      else
        @hideHeaderContainer()
        @hideFooterContainer()
        @hideContentContainer()
        @showEmptyMessageContainer()
  
    sendDataToTemplate: ($specificElem) ->
  
      $item_template = $('#' + $specificElem.attr('data-hb-template'))
      $append_to = $specificElem
  
      # use special configuration config for cards if available
      if @isCards() and @collection.getMeta('columns_card').length > 0
        visibleColumns = @collection.getMeta('columns_card')
      else
        defaultVisibleColumns = _.filter(@collection.getMeta('columns'), (col) -> col.show)
        additionalVisibleColumns = _.filter(@collection.getMeta('additional_columns'), (col) -> col.show)
        visibleColumns = _.union(defaultVisibleColumns, additionalVisibleColumns)
  
      # if it is a table, add the corresponding header
      if $specificElem.is('table')
  
        header_template = $('#' + $specificElem.attr('data-hb-header-template'))
        header_row_cont = Handlebars.compile( header_template.html() )
          base_check_box_id: @getBaseSelectAllCheckBoxID()
          all_items_selected: @collection.getMeta('all_items_selected')
          columns: visibleColumns
  
        $specificElem.append($(header_row_cont))
        # make sure that the rows are appended to the tbody, otherwise the striped class won't work
        $specificElem.append($('<tbody>'))
  
  
      selectionExceptions = @collection.getMeta('selection_exceptions')
      allAreSelected =  @collection.getMeta('all_items_selected')
  
      for item in @collection.getCurrentPage()
  
        img_url = ''
        # handlebars only allow very simple logic, we have to help the template here and
        # give it everything as ready as possible
  
        columnsWithValues = visibleColumns.map (col_desc) ->
          return_col = {}
          return_col.name_to_show = col_desc['name_to_show']
          
          col_value = glados.Utils.getNestedValue(item.attributes, col_desc.comparator)
  
          if _.isBoolean(col_value)
            return_col['value'] = if col_value then 'Yes' else 'No'
          else
            return_col['value'] = col_value
  
          if _.has(col_desc, 'parse_function')
            return_col['value'] = col_desc['parse_function'](col_value)
  
          return_col['has_link'] = _.has(col_desc, 'link_base')
          return_col['link_url'] = item.get(col_desc['link_base']) unless !return_col['has_link']
          if _.has(col_desc, 'image_base_url')
            img_url = item.get(col_desc['image_base_url'])
            return_col['img_url'] = img_url
          if _.has(col_desc, 'custom_field_template')
            return_col['custom_html'] = Handlebars.compile(col_desc['custom_field_template'])
              val: return_col['value']
  
          # This method should return a value based on the parameter, not modify the parameter
          return return_col
  
        isColumnValue = glados.Utils.getNestedValue(item.attributes, @collection.getMeta('id_column').comparator)
  
        isSelectionException =  selectionExceptions[isColumnValue]?
  
        new_item_cont = Handlebars.compile( $item_template.html() )
          base_check_box_id: isColumnValue
          is_selected: isSelectionException != allAreSelected
          img_url: img_url
          columns: columnsWithValues
  
        $append_to.append($(new_item_cont))
  
      # After adding everything, if the element is a table I now set up the top scroller
      # also set up the automatic header fixation
      if $specificElem.is('table') and $specificElem.hasClass('scrollable')
  
        $topScrollerDummy = $(@el).find('.BCK-top-scroller-dummy')
        $firstTableRow = $specificElem.find('tr').first()
        firstRowWidth = $firstTableRow.width()
        tableWidth = $specificElem.width()
        $topScrollerDummy.width(firstRowWidth)
  
        hasToScroll = tableWidth < firstRowWidth
        if hasToScroll and GlobalVariables.CURRENT_SCREEN_TYPE != GlobalVariables.SMALL_SCREEN
          $topScrollerDummy.height(20)
        else
          $topScrollerDummy.height(0)
  
        # bind the scroll functions if not done yet
        if !$specificElem.attr('data-scroll-setup')
  
          @setUpTopTableScroller($specificElem)
          $specificElem.attr('data-scroll-setup', true)
  
        # now set up tha header fixation
        if !$specificElem.attr('data-header-pinner-setup')
  
          # delay this to wait for
          @setUpTableHeaderPinner($specificElem)
          $specificElem.attr('data-header-pinner-setup', true)
  
      # This code completes rows for grids of 2 or 3 columns in the flex box css display
      total_cards = @collection.getCurrentPage().length
      while total_cards%6 != 0
        $append_to.append('<div class="col s12 m6 l4"/>')
        total_cards++
  
    # ------------------------------------------------------------------------------------------------------------------
    # Table scroller
    # ------------------------------------------------------------------------------------------------------------------
    # this sets up dor a table the additional scroller on top of the table
    setUpTopTableScroller: ($table) ->
  
      $scrollContainer = $(@el).find('.BCK-top-scroller-container')
      $scrollContainer.scroll( -> $table.scrollLeft($scrollContainer.scrollLeft()))
      $table.scroll( -> $scrollContainer.scrollLeft($table.scrollLeft()))
  
  
    # ------------------------------------------------------------------------------------------------------------------
    # Table header pinner
    # ------------------------------------------------------------------------------------------------------------------
    setUpTableHeaderPinner: ($table) ->
  
      console.log 'setting up table header pinner'
  
      #use the top scroller to trigger the pin
      $scrollContainer = $(@el).find('.BCK-top-scroller-container')
      $firstTableRow = $table.find('tr').first()
  
      $win = $(window)
      topTrigger = $scrollContainer.offset().top
  
      pinUnpinTableHeader = ->
  
        # don't bother if table is not shown
        if !$table.is(":visible")
          return
  
        #TODO: complete this function!
  
      $win.scroll _.throttle(pinUnpinTableHeader, 200)
  
    fillPaginators: ->
  
      $elem = $(@el).find('.BCK-paginator-container')
      template = $('#' + $elem.attr('data-hb-template'))
  
      current_page = @collection.getMeta('current_page')
      records_in_page = @collection.getMeta('records_in_page')
      page_size = @collection.getMeta('page_size')
      num_pages = @collection.getMeta('total_pages')
  
      first_record = (current_page - 1) * page_size
      last_page = first_record + records_in_page
  
      # this sets the window for showing the pages
      show_previous_ellipsis = false
      show_next_ellipsis = false
      if num_pages <= 5
        first_page_to_show = 1
        last_page_to_show = num_pages
      else if current_page + 2 <= 5
        first_page_to_show = 1
        last_page_to_show = 5
        show_next_ellipsis = true
      else if current_page + 2 < num_pages
        first_page_to_show = current_page - 2
        last_page_to_show = current_page + 2
        show_previous_ellipsis = true
        show_next_ellipsis = true
      else
        first_page_to_show = num_pages - 4
        last_page_to_show = num_pages
        show_previous_ellipsis = true
  
      pages = (num for num in [first_page_to_show..last_page_to_show])
  
      $elem.html Handlebars.compile(template.html())
        pages: pages
        records_showing: (first_record+1) + '-' + last_page
        total_records: @collection.getMeta('total_records')
        show_next_ellipsis: show_next_ellipsis
        show_previous_ellipsis: show_previous_ellipsis
  
      @activateCurrentPageButton()
      @enableDisableNextLastButtons()
  
    getBaseSelectAllCheckBoxID: ->
  
      baseCheckBoxID = $(@el).attr('id')
      # Parent element should always have an id, if for some reason it hasn't we generate a random number for the id
      # we need this to avoid conflicts with other tables on the page that will have also a header and a "select all"
      # option
      if !baseCheckBoxID?
        baseCheckBoxID = Math.floor((Math.random() * 1000) + 1)
  
      return baseCheckBoxID
  
  
    fillSelectAllContainer: ->
      $selectAllContainer = $(@el).find('.BCK-selectAll-container')
      if $selectAllContainer.length == 0
        return
      glados.Utils.fillContentForElement $selectAllContainer,
        base_check_box_id: @getBaseSelectAllCheckBoxID()
  
    fillNumResults: ->
  
      glados.Utils.fillContentForElement $(@el).find('.num-results'),
        num_results: @collection.getMeta('total_records')
  
    getPageEvent: (event) ->
  
      clicked = $(event.currentTarget)
  
      # Don't bother if the link was disabled.
      if clicked.hasClass('disabled')
        return
  
      @showPaginatedViewPreloader() unless @collection.getMeta('server_side') != true
  
      pageNum = clicked.attr('data-page')
      @requestPageInCollection(pageNum)
  
  
    requestPageInCollection: (pageNum) ->
  
      currentPage = @collection.getMeta('current_page')
      totalPages = @collection.getMeta('total_pages')
  
      if pageNum == "previous"
        pageNum = currentPage - 1
      else if pageNum == "next"
        pageNum = currentPage + 1
  
      # Don't bother if the user requested is greater than the max number of pages
      if pageNum > totalPages
        return
  
      @collection.setPage(pageNum)
  
  
    enableDisableNextLastButtons: ->
  
      current_page = parseInt(@collection.getMeta('current_page'))
      total_pages = parseInt(@collection.getMeta('total_pages'))
  
      if current_page == 1
        $(@el).find("[data-page='previous']").addClass('disabled')
      else
        $(@el).find("[data-page='previous']").removeClass('disabled')
  
      if current_page == total_pages
        $(@el).find("[data-page='next']").addClass('disabled')
      else
        $(@el).find("[data-page='next']").removeClass('disabled')
  
    activateCurrentPageButton: ->
  
      current_page = @collection.getMeta('current_page')
      $(@el).find('.page-selector').removeClass('active')
      $(@el).find("[data-page=" + current_page + "]").addClass('active')
  
    changePageSize: (event) ->
  
      @showPaginatedViewPreloader() unless @collection.getMeta('server_side') != true
      selector = $(event.currentTarget)
      new_page_size = selector.val()
      # this is an issue with materialise, it fires 2 times the event, one of which has an empty value
      if new_page_size == ''
        return
      @collection.resetPageSize(new_page_size)
  
    # ------------------------------------------------------------------------------------------------------------------
    # Search
    # ------------------------------------------------------------------------------------------------------------------
    setSearch: _.debounce( (event) ->
  
      $searchInput = $(event.currentTarget)
      term = $searchInput.val()
      # if the collection is client side the column and data type will be undefined and will be ignored.
      column = $searchInput.attr('data-column')
      type = $searchInput.attr('data-column-type')
  
      @triggerSearch(term, column, type)
  
    , glados.Settings['SEARCH_INPUT_DEBOUNCE_TIME'])
  
    # this closes the function setNumeric search with a jquery element, the idea is that
    # you can get the attributes such as the column for the search, and min and max values
    # from the jquery element
    setNumericSearchWrapper: ($elem) ->
  
      ctx = @
      setNumericSearch = _.debounce( (values, handle) ->
  
        term =  values.join(',')
        column = $elem.attr('data-column')
        type = $elem.attr('data-column-type')
  
        ctx.triggerSearch(term, column, type)
      , glados.Settings['SEARCH_INPUT_DEBOUNCE_TIME'])
  
  
      return setNumericSearch
  
  
    triggerSearch:  (term, column, type) ->
  
      @clearContentContainer()
      @showPaginatedViewPreloader()
  
      @collection.setSearch(term, column, type)
  
    # ------------------------------------------------------------------------------------------------------------------
    # Add Remove Columns
    # ------------------------------------------------------------------------------------------------------------------
    initialiseColumnsModal: ->
  
      $dropdownContainer = $(@el).find('.BCK-show-hide-columns-container')
  
      if $dropdownContainer.length == 0
        return
      $dropdownContainer.html Handlebars.compile($('#' + $dropdownContainer.attr('data-hb-template')).html())
        modal_id: $(@el).attr('id') + '-select-columns-modal'
        columns: @collection.getMeta('columns')
        additional_columns: @collection.getMeta('additional_columns')
  
      $(@el).find('.modal').modal()
  
    showHideColumn: (event) ->
  
  
      $checkbox = $(event.currentTarget)
      colComparator = $checkbox.attr('data-comparator')
      isChecked = $checkbox.is(':checked')
  
      allColumns = _.union(@collection.getMeta('columns'), @collection.getMeta('additional_columns'))
      changedColumn = _.find(allColumns, (col) -> col.comparator == colComparator)
      changedColumn.show = isChecked
      @clearTemplates()
      @fillTemplates()
  
    # ------------------------------------------------------------------------------------------------------------------
    # Sort
    # ------------------------------------------------------------------------------------------------------------------
  
    sortCollection: (event) ->
  
      @showPaginatedViewPreloader() unless @collection.getMeta('server_side') != true
      order_icon = $(event.currentTarget)
      comparator = order_icon.attr('data-comparator')
  
      @triggerCollectionSort(comparator)
  
    triggerCollectionSort: (comparator) ->
  
      @clearContentContainer()
      @showPaginatedViewPreloader()
  
      @collection.sortCollection(comparator)
  
    # ------------------------------------------------------------------------------------------------------------------
    # Preloaders and content
    # ------------------------------------------------------------------------------------------------------------------
    showPaginatedViewContent: ->
  
      $preloaderCont = $(@el).find('.BCK-PreloaderContainer')
      $contentCont =  $(@el).find('.BCK-items-container')
  
      $preloaderCont.hide()
      $contentCont.show()
  
    showPaginatedViewPreloader: ->
  
      $preloaderCont = $(@el).find('.BCK-PreloaderContainer')
      $contentCont =  $(@el).find('.BCK-items-container')
  
      $preloaderCont.show()
      $contentCont.hide()
  
    # show the preloader making sure the content is also visible, useful for the infinite browser
    showPaginatedViewPreloaderAndContent: ->
  
      $preloaderCont = $(@el).find('.BCK-PreloaderContainer')
      $contentCont =  $(@el).find('.BCK-items-container')
  
      $preloaderCont.show()
      $contentCont.show()
  
    clearContentContainer: ->
      $(@el).find('.BCK-items-container').empty()
      @hideEmptyMessageContainer()
      @showContentContainer()
  
    showPreloaderOnly: ->
      $preloaderCont = $(@el).find('.BCK-PreloaderContainer')
      $preloaderCont.show()
  
    hidePreloaderOnly: ->
      $preloaderCont = $(@el).find('.BCK-PreloaderContainer')
      $preloaderCont.hide()
  
    hideHeaderContainer: ->
      $headerRow = $(@el).find('.BCK-header-container')
      $headerRow.hide()
  
    hideFooterContainer: ->
      $headerRow = $(@el).find('.BCK-footer-container')
      $headerRow.hide()
  
    showFooterContainer: ->
      $headerRow = $(@el).find('.BCK-footer-container')
      $headerRow.show()
  
    hideContentContainer: ->
      $headerRow = $(@el).find('.BCK-items-container')
      $headerRow.hide()
  
    showContentContainer: ->
      $headerRow = $(@el).find('.BCK-items-container')
      $headerRow.show()
  
    hideEmptyMessageContainer: ->
      $headerRow = $(@el).find('.BCK-EmptyListMessage')
      $headerRow.hide()
  
    showEmptyMessageContainer: ->
      $headerRow = $(@el).find('.BCK-EmptyListMessage')
      $headerRow.show()
  
    showPreloaderHideOthers: ->
      @showPreloaderOnly()
      @hideHeaderContainer()
      @hideContentContainer()
      @hideEmptyMessageContainer()
      @hideFooterContainer()
  
  
    # ------------------------------------------------------------------------------------------------------------------
    # Infinite Browser
    # ------------------------------------------------------------------------------------------------------------------
  
    showNumResults: ->
  
      $(@el).children('.num-results').show()
  
    hideNumResults: ->
  
      $(@el).children('.num-results').hide()
  
  
    setUpLoadingWaypoint: ->
  
      $cards = $('.BCK-items-container').children()
  
      # don't bother when there aren't any cards
      if $cards.length == 0
        return
  
      $middleCard = $cards[Math.floor($cards.length / 4)]
  
      # the advancer function requests always the next page
      advancer = $.proxy ->
        #destroy waypoint to avoid issues with triggering more page requests.
        Waypoint.destroyAll()
        # dont' bother if already on last page
        if @collection.currentlyOnLastPage()
          return
        @showPaginatedViewPreloaderAndContent()
        @requestPageInCollection('next')
      , @
  
      # destroy all waypoints before assigning the new one.
      Waypoint.destroyAll()
  
      waypoint = new Waypoint(
        element: $middleCard
        handler: (direction) ->
  
          if direction == 'down'
            advancer()
  
      )
  
    # checks if there are more page and hides the preloader if there are no more.
    hidePreloaderIfNoNextItems: ->
  
      if @collection.currentlyOnLastPage()
        @hidePreloaderOnly()
  
    # ------------------------------------------------------------------------------------------------------------------
    # sort selector
    # ------------------------------------------------------------------------------------------------------------------
  
    renderSortingSelector: ->
  
      $selectSortContainer = $(@el).find('.select-sort-container')
      $selectSortContainer.empty()
  
      $template = $('#' + $selectSortContainer.attr('data-hb-template'))
      columns = @collection.getMeta('columns')
  
      col_comparators = _.map(columns, (col) -> {comparator: col.comparator, selected: col.is_sorting != 0})
      one_selected = _.reduce(col_comparators, ((a, b) -> a.selected or b.selected), 0 )
  
      $selectSortContainer.html Handlebars.compile( $template.html() )
        columns: col_comparators
        one_selected: one_selected
  
      $btnSortDirectionContainer = $(@el).find('.btn-sort-direction-container')
      $btnSortDirectionContainer.empty()
  
      $template = $('#' + $btnSortDirectionContainer.attr('data-hb-template'))
  
  
      # relates the sort direction with a class and a text for the template
      sortClassAndText =
        '-1': {sort_class: 'fa-sort-desc', text: 'Desc'},
        '0': {sort_class: 'fa-sort', text: ''},
        '1': {sort_class: 'fa-sort-asc', text: 'Asc'}
  
      currentSortDirection = _.reduce(_.pluck(columns, 'is_sorting'), ((a, b) -> a + b), 0)
      currentProps = sortClassAndText[currentSortDirection.toString()]
  
      $btnSortDirectionContainer.html Handlebars.compile( $template.html() )
        sort_class:  currentProps.sort_class
        text: currentProps.text
        disabled: currentSortDirection == 0
  
  
    sortCollectionFormSelect: (event) ->
  
      @showPaginatedViewPreloader()
  
      selector = $(event.currentTarget)
      comparator = selector.val()
  
      if comparator == ''
        return
  
      @triggerCollectionSort(comparator)
  
    changeSortOrderInf: ->
  
      comp = @collection.getCurrentSortingComparator()
      if comp?
        @triggerCollectionSort(comp)
  
  
    # ------------------------------------------------------------------------------------------------------------------
    # Page selector
    # ------------------------------------------------------------------------------------------------------------------
  
    fillPageSelectors: ->
  
      $elem = $(@el).find('.BCK-select-page-size-container')
      $contentTemplate = $('#' + $elem.attr('data-hb-template'))
  
      currentPageSize = @collection.getMeta('page_size')
      pageSizesItems = []
  
      for size in @collection.getMeta('available_page_sizes')
        item = {}
        item.number = size
        item.is_selected = currentPageSize == size
        pageSizesItems.push(item)
  
      $elem.html Handlebars.compile( $contentTemplate.html() )
        items: pageSizesItems
  
    activateSelectors: ->
  
      $(@el).find('select').material_select()
  
    # ------------------------------------------------------------------------------------------------------------------
    # Error handling
    # ------------------------------------------------------------------------------------------------------------------
    handleError: (model, xhr, options) ->
  
      if xhr.responseJSON?
        message = xhr.responseJSON.error_message
        if not message?
          message = xhr.responseJSON.error
      else
        message = 'There was an error while handling your request'
  
  
      $(@el).find('.BCK-PreloaderContainer').hide()
      $(@el).find('.BCK-ErrorMessagesContainer').html Handlebars.compile($('#Handlebars-Common-CollectionErrorMsg').html())
        msg: message


# ----------------------------------------------------------------------------------------------------------------------
# Class Context
# ----------------------------------------------------------------------------------------------------------------------

glados.views.PaginatedViews.PaginatedView.CARDS_TYPE = 'CARDS_TYPE'
glados.views.PaginatedViews.PaginatedView.CAROUSEL_TYPE = 'CAROUSEL_TYPE'
glados.views.PaginatedViews.PaginatedView.INFINITE_TYPE = 'INFINITE_TYPE'
glados.views.PaginatedViews.PaginatedView.TABLE_TYPE = 'TABLE_TYPE'

glados.views.PaginatedViews.PaginatedView.getNewTablePaginatedView = (collection, el)->
  return new glados.views.PaginatedViews.PaginatedView
    collection: collection
    el: el
    type: glados.views.PaginatedViews.PaginatedView.TABLE_TYPE

glados.views.PaginatedViews.PaginatedView.getTypeConstructor = (pagViewType)->
  tmp_constructor = ()->
    arguments[0].type = pagViewType
    glados.views.PaginatedViews.PaginatedView.apply(@, arguments)
  tmp_constructor.prototype = glados.views.PaginatedViews.PaginatedView.prototype
  return tmp_constructor

glados.views.PaginatedViews.PaginatedView.getTableConstructor = ()->
  return glados.views.PaginatedViews.PaginatedView\
    .getTypeConstructor(glados.views.PaginatedViews.PaginatedView.TABLE_TYPE)
