# Base view for most of the cards in the page
# make sure the handlebars templates are loaded!
CardView = Backbone.View.extend

  showCompoundErrorCard: (model, xhr, options) ->
    $(@el).children('.card-preolader-to-hide').hide()

    if xhr.status == 404
      error_msg = 'No compound found with id ' + @model.get('molecule_chembl_id')
    else
      error_msg = 'There was an error while loading the compound (' + xhr.status + ' ' + xhr.statusText + ')'

    rendered = Handlebars.compile($('#Handlebars-Common-CardError').html())
      msg: error_msg

    $(@el).children('.card-load-error').find('.Bck-errormsg').html(rendered)

    $(@el).children('.card-load-error').show()

    $(@el).find('#Bck-CHEMBL_ID')

  initEmbedModal: (section_name) ->

    if EMBEDED?
      # prevent unnecessary loops
      $(@el).find('.embed-modal-trigger').remove()
      $(@el).find('.embed-modal').remove()
      return

    modal_trigger = $(@el).find('.embed-modal-trigger')

    modal = $(@el).find('.embed-modal')
    modal_id = 'embed-modal-for-' + $(@el).attr('id')
    modal.attr('id', modal_id)
    modal_trigger.attr('href', '#' + modal_id)

    code_elem = modal.find('code')

    chembl_id = if @model? then @model.get('molecule_chembl_id') else CHEMBL_ID

    rendered = Handlebars.compile($('#Handlebars-Common-EmbedCode').html())
      chembl_id: chembl_id
      section_name: section_name

    code_elem.text(rendered)

  renderModalPreview: ->

    if EMBEDED?
      return

    modal = $(@el).find('.embed-modal')
    preview_elem = modal.find('.embed-preview')

    code_elem = modal.find('code')
    code_to_preview = code_elem.text()

    preview_elem.html(code_to_preview)

  activateTooltips: ->
    $(@el).find('.tooltipped').tooltip()


