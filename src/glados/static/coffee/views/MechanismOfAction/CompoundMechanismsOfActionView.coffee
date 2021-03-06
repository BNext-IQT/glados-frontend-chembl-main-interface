# View that renders the Compound Mechanisms of Action section
# of the compound report card
# load CardView first!
# also make sure the html can access the handlebars templates!
CompoundMechanismsOfActionView = CardView.extend

  initialize: ->
    CardView.prototype.initialize.call(@, arguments)
    @collection.on 'reset', @render, @
    @collection.on 'error', @.showCompoundErrorCard, @
    @resource_type = 'Compound'
    @molecule_chembl_id = arguments[0].molecule_chembl_id

  render: ->

    if @collection.size() == 0
      return

    @showSection()
    @addAllMechanisms()

    # until here, all the visible content has been rendered.
    @showCardContent()

    @initEmbedModal('mechanism_of_action', @molecule_chembl_id)
    @activateTooltips()
    @activateModals()

  addOneMechanism: (mechanismOfAction) ->
    view = new MechanismOfActionRowView({model: mechanismOfAction});
    table = $(@el).find('table')
    table.append(view.render().el)

    collItemView = new MechanismOfActionCollItemView({model:mechanismOfAction})
    coll = $(@el).find('ul')
    coll.append(collItemView.render().el)

  addAllMechanisms: ->
    @collection.forEach @addOneMechanism, @


