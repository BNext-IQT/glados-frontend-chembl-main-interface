glados.useNameSpace 'glados.views.PaginatedViews',
  PaginationFunctions:

    initPageNumber: -> @currentPageNum = 1
    initAvailablePageSizes: ->

      @AVAILABLE_PAGE_SIZES ?= [5, 10, 20, 50, 100]

      defaultPageSize = @collection.getMeta('default_page_size')
      if defaultPageSize?
        @currentPageSize = defaultPageSize
      else
        @currentPageSize = @AVAILABLE_PAGE_SIZES[2]

    requestCurrentPage: ->
      @collection.setPage(@currentPageNum, doFetch=true, testMode=false, customPageSize=@currentPageSize)

    getPageEvent: (event) ->

      clicked = $(event.currentTarget)
      if not @eventForThisView(clicked)
        return

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

      @currentPageNum = parseInt(pageNum)
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

      selector = $(event.currentTarget)
      if not @eventForThisView(selector)
        return

      @showPaginatedViewPreloader() unless @collection.getMeta('server_side') != true

      newPageSize = selector.val()
      # this is an issue with materialise, it fires 2 times the event, one of which has an empty value
      if newPageSize == ''
        return

      @requestPageSizeInCollection(newPageSize)

    requestPageSizeInCollection: (newPageSize) ->

      @currentPageNum = 1
      @currentPageSize = parseInt(newPageSize)
      @collection.resetPageSize(newPageSize)

    hidePaginators: ->

      $elem = $(@el).find('.BCK-paginator-container')
      if $elem.length == 0
        return

      $elem.hide()

    hideFooter: ->

      $elem = $(@el).find('.BCK-footer-container')
      $elemChevrons = $(@el).find('.BCK-chevrons-container')
      if $elem.length == 0
        return

      $elem.addClass('row-hidden')
      $elemChevrons.addClass('row-hidden')
      $elem.hide()
      $elemChevrons.hide()

    fillPaginators: ->

      $elem = $(@el).find('.BCK-paginator-container')
      if $elem.length == 0
        return
      template = $('#' + $elem.attr('data-hb-template'))
      current_page = @collection.getMeta('current_page')
#      console.log 'current_page: ', current_page
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
        records_showing: glados.Utils.getFormattedNumber(first_record+1) + '-' + \
          glados.Utils.getFormattedNumber(last_page)
        total_records: glados.Utils.getFormattedNumber(@collection.getMeta('total_records'))
        show_next_ellipsis: show_next_ellipsis
        show_previous_ellipsis: show_previous_ellipsis

      @activateCurrentPageButton()
      @enableDisableNextLastButtons()


