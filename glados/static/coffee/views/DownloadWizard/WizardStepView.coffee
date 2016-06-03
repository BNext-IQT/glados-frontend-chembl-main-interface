# View that takes care of handling the interaction of the user in the
# download wizard.
WizardStepView = Backbone.View.extend

  initialize: ->
    @model.on 'change', @.render, @
    @model.on 'error', @.showErrorMsg, @
    @setPreloader()

  events:
    "click .db-menu-link": "goToStep"

  render: ->

    @hidePreloader()
    $(this.el).html Handlebars.compile($('#Handlebars-DownloadWizard-step').html())
      title: @model.get('title')
      options: @model.get('options')
      description: @model.get('description')
      previous_step: @model.get('previous_step')
      hide_previous_step: !@model.get('previous_step')?
      right_option: @model.get('right_option')
      hide_right_option: !@model.get('right_option')?
      left_option: @model.get('left_option')
      hide_left_option: !@model.get('left_option')?

  goToStep: (event) ->

    @setPreloader()
    next_url = '/download_wizard/' + $(event.currentTarget).attr('href').substring(1)
    @model.url = next_url
    @model.fetch()

  hidePreloader: ->
    $(@el).find('.card-preolader-to-hide').hide()

  setPreloader: ->
    $(this.el).html Handlebars.compile($('#Handlebars-Common-Preloader').html())

  showErrorMsg: ->

    $(this.el).html Handlebars.compile($('#Handlebars-DownloadWizard-error').html())
      msg: 'There was an error loading the next step'




