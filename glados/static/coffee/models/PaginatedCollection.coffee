# This class implements the pagination, sorting and searching for a collection
# extend it to get a collection with the extra capabilities
PaginatedCollection = Backbone.Collection.extend

  setMeta: (attr, value) ->
    @meta[attr] = parseInt(value)
    @trigger('meta-changed')

  getMeta: (attr) ->
    return @meta[attr]

  resetPageSize: (new_page_size) ->

    if @getMeta('server_side') == true
      @resetPageSizeSS(new_page_size)
    else
      @resetPageSizeC(new_page_size)




  # assuming that I have all the records.
  # Meta data is:
  #  server_side -- true if you expect that each page is fetched on demand by the server.
  #  total_records
  #  current_page
  #  total_pages
  #  records_in_page -- How many records are in the current page
  #  sorting data per column.
  #
  resetMeta: (page_meta) ->

    console.log('resetting meta')
    if @getMeta('server_side') == true
      @resetMetaSS(page_meta)
    else
      @resetMetaC()

  calculateTotalPages: ->

    total_pages =  Math.ceil(@models.length / @getMeta('page_size'))
    @setMeta('total_pages', total_pages)

  calculateHowManyInCurrentPage: ->

    current_page = @getMeta('current_page')
    total_pages = @getMeta('total_pages')
    total_records = @getMeta('total_records')
    page_size = @getMeta('page_size')

    if total_pages == 1
      @setMeta('records_in_page', total_records )
      console.log('CASE1')
    else if current_page == total_pages
      console.log('CASE2')
      @setMeta('records_in_page', total_records % page_size)
    else
      console.log('CASE3')
      @setMeta('records_in_page', @getMeta('page_size'))

  getCurrentPage: ->

    if @getMeta('server_side') == true
      @getCurrentPageSS()
    else
      @getCurrentPageC()

  setPage: (page_num) ->

    if @getMeta('server_side') == true
      @setPageSS(page_num)
    else
      @setPageC(page_num)

  sortCollection: (comparator) ->

    if @getMeta('server_side') == true
      @sortCollectionSS(comparator)
    else
      @sortCollectionC(comparator)


  resetSortData: ->

    @comparator = undefined
    columns = @getMeta('columns')
    for col in columns
      col.is_sorting = 0
      col.sort_class = 'fa-sort'

  # organises the information of the columns that are going to be sorted.
  # returns true if the sorting needs to be descending, false otherwise.
  setupColSorting: (columns, comparator) ->

    is_descending = false

    for col in columns

      # set is_sorting attribute for the comparator column
      if col.comparator == comparator

        col.is_sorting = switch col.is_sorting
          when 0 then 1
          else -col.is_sorting

        is_descending = col.is_sorting == -1

      else
      # for the rest of the columns is zero
        col.is_sorting = 0

      # now set the class for font-awesome
      # this was the simplest way I found to do it, handlebars doesn't provide a '==' expression

      col.sort_class = switch col.is_sorting
        when -1 then 'fa-sort-desc'
        when 0 then 'fa-sort'
        when 1 then 'fa-sort-asc'

    return is_descending



  # ------------------------------------------------------------
  # -- Client Side!!!
  # ------------------------------------------------------------

  resetMetaC: ->

    console.log('reset meta client side!')

    @setMeta('total_records', @models.length)
    @setMeta('current_page', 1)
    @calculateTotalPages()
    @calculateHowManyInCurrentPage()
    @resetSortData()

  getCurrentPageC: ->

    console.log '---'
    console.log 'giving current page'
    page_size = @getMeta('page_size')
    current_page = @getMeta('current_page')
    records_in_page = @getMeta('records_in_page')

    start = (current_page - 1) * page_size
    end = start + records_in_page

    console.log 'page_size'
    console.log page_size
    console.log 'current_page'
    console.log current_page
    console.log 'records_in_page'
    console.log records_in_page

    console.log 'start'
    console.log start
    console.log 'end'
    console.log end

    to_show = @models[start..end]
    @setMeta('to_show', to_show)

    console.log 'to_show'
    console.log to_show

    console.log '^^^'

    return to_show

  setPageC: (page_num) ->

    @setMeta('current_page', page_num)
    @trigger('do-repaint')

  resetPageSizeC: (new_page_size) ->

    if new_page_size == ''
      return

    @setMeta('page_size', new_page_size)
    @setMeta('current_page', 1)
    @calculateTotalPages()
    @calculateHowManyInCurrentPage()
    @trigger('do-repaint')

  sortCollectionC: (comparator) ->

    @comparator = comparator
    columns = @getMeta('columns')
    is_descending = @setupColSorting(columns, comparator)

    # check if sorting is descending
    if is_descending
      @sort({silent: true})
      @models = @models.reverse()
      @trigger('sort')
    else
      @sort()

  # ------------------------------------------------------------
  # -- Server Side!!!
  # ------------------------------------------------------------

  resetMetaSS: (page_meta) ->

    @setMeta('total_records', page_meta.total_count)
    @setMeta('page_size', page_meta.limit)
    @setMeta('current_page', (page_meta.offset / page_meta.limit) + 1)
    @setMeta('total_pages', Math.ceil(page_meta.total_count / page_meta.limit) )
    @setMeta('records_in_page', page_meta.records_in_page )

  getCurrentPageSS: ->

    # allways the models represent the current page
    return @models

  setPageSS: (page_num) ->

    base_url = @getMeta('base_url')
    @url = @getPaginatedURL(base_url, page_num)
    @fetch()

  getPaginatedURL: (url, page_num) ->

    page_size = @getMeta('page_size')

    limit_str = 'limit=' + page_size
    page_str = 'offset=' + (page_num - 1) * page_size
    full_url = url + '&' + limit_str + '&' + page_str

    columns = @getMeta('columns')

    sorting = _.filter(columns, (col) -> col.is_sorting != 0)
    for field in sorting
      comparator = field.comparator
      comparator = '-' + comparator unless field.is_sorting == 1
      full_url += '&order_by=' + comparator

    return full_url

  resetPageSizeSS: (new_page_size) ->

    if new_page_size == ''
      return

    @setMeta('page_size', new_page_size)
    @setPage(1)

  sortCollectionSS: (comparator) ->

    columns = @getMeta('columns')
    @setupColSorting(columns, comparator)
    @url = @getPaginatedURL(@getMeta('base_url'), @getMeta('current_page'))
    @fetch()
