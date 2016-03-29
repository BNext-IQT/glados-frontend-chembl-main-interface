MechanismOfActionRowView = Backbone.View.extend

  tagName: 'tr'

  initialize: ->
    @model.on 'change', @.render, @

  render: ->

    rendered = Handlebars.compile($('#Handlebars-Compound-MechanismOfAction-tds').html())
      mechanism_of_action: @model.get('mechanism_of_action')
      target_chembl_id: @model.get('target_chembl_id')

    $(this.el).html(rendered);
    console.log($(this.el).html())
