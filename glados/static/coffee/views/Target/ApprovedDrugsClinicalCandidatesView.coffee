# View that renders the Approved drugs and clinical candidates section
# from the target report card
# load CardView first!
ApprovedDrugsClinicalCandidatesView = CardView.extend

  initialize: ->
    @collection.on 'reset', @.render, @
    @resource_type = 'Target'

  events:
    'click .page-selector': 'getPage'

  render: ->

    if @collection.size() == 0
      $('#ApprovedDrugsAndClinicalCandidates').hide()
      return

    @clearTable()
    @clearList()

    @fill_template('ADCCTable-large')
    @fill_template('ADCCUL-small')
    @fillPaginator()

    @showVisibleContent()
    @initEmbedModal('approved_drugs_clinical_candidates')
    @activateModals()


  fill_template: (elem_id) ->

    elem = $(@el).find('#' + elem_id)
    template = $('#' + elem.attr('data-hb-template'))

    for adcc in @collection.models

      new_row_cont = Handlebars.compile( template.html() )
        molecule_chembl_id: adcc.get('molecule_chembl_id')
        pref_name: adcc.get('pref_name')
        mechanism_of_action: adcc.get('mechanism_of_action')
        max_phase: adcc.get('max_phase')

      elem.append($(new_row_cont))

  fillPaginator: ->

    elem = $(@el).find('#ADCCUL-paginator')
    template = $('#' + elem.attr('data-hb-template'))
    console.log(@collection.getMeta('total_records'))

    current_page = @collection.getMeta('current_page')
    records_in_page = @collection.getMeta('records_in_page')
    console.log('records in page')
    console.log(records_in_page)
    page_size = @collection.getMeta('page_size')

    first_record = (current_page - 1) * page_size
    last_page = first_record + records_in_page

    elem.html Handlebars.compile(template.html())
      records_showing: first_record + '-' + last_page
      total_records: @collection.getMeta('total_records')

    @activateCurrentPageButton()

  clearTable: ->

    $('#ADCCTable-large tr:gt(0)').remove()

  clearList: ->

    $('#ADCCUL-small').empty()

  getPage: (event) ->

    clicked = $(event.currentTarget)
    requested_page_num = clicked.attr('data-page')
    current_page = @collection.getMeta('current_page')

    console.log('current_page')
    console.log(current_page)
    # Don't bother if the user requested the same page as the current one
    if current_page == requested_page_num
      return

    if requested_page_num == "previous"
      requested_page_num = current_page - 1
    else if requested_page_num == "next"
      requested_page_num = current_page + 1

    console.log('going to fetch')
    console.log(requested_page_num)
    @collection.fetchPage(requested_page_num)
    @showPreloader()

  enableDisableNextLastButtons: ->

  activateCurrentPageButton: ->

    current_page = @collection.getMeta('current_page')
    $(@el).find('.page-selector').removeClass('active')
    $(@el).find("[data-page=" + current_page + "]").addClass('active')




    



