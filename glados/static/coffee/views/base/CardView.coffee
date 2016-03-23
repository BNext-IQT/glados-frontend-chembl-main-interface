# Base view for most of the cards in the page
CardView = Backbone.View.extend

  showCompoundErrorCard: (model, xhr, options) ->
    $(@el).children('.card-preolader-to-hide').hide()

    if xhr.status == 404
      error_msg = 'No compound found with id ' + @model.get('molecule_chembl_id')
    else
      error_msg = 'There was an error while loading the compound (' + xhr.status + ' ' + xhr.statusText + ')'

    source = '<i class="fa fa-exclamation-circle"></i> {{msg}}'
    rendered = Handlebars.compile(source)
      msg: error_msg

    $(@el).children('.card-load-error').find('.Bck-errormsg').html(rendered)

    $(@el).children('.card-load-error').show()

    $(@el).find('#Bck-CHEMBL_ID')

