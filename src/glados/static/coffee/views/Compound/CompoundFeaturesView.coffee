# View that renders the Molecule Features section
# from the compound report card
CompoundFeaturesView = CardView.extend

  initialize: ->
    @model.on 'change', @.render, @
    @model.on 'error', @.showCompoundErrorCard, @
    @resource_type = 'Compound'

  render: ->

    @renderProperty('Bck-MolType', 'molecule_type')
    @renderProperty('Bck-RuleOfFive', 'ro5')
    @renderProperty('Bck-FirstInClass', 'first_in_class')
    @renderProperty('Bck-Chirality', 'chirality')
    @renderProperty('Bck-Prodrug', 'prodrug')
    @renderProperty('Bck-Oral', 'oral')
    @renderProperty('Bck-Parenteral', 'parenteral')
    @renderProperty('Bck-Topical', 'topical')
    @renderProperty('Bck-BlackBox', 'black_box_warning')
    @renderProperty('Bck-Availability', 'availability_type')

    # until here, all the visible content has been rendered.
    @showCardContent()

    @initEmbedModal('molecule_features')
    @activateModals()

    @activateTooltips()

  renderProperty: (div_id, property) ->
    property_div = $(@el).find('#' + div_id)

    property_div.html Handlebars.compile($('#Handlebars-Compound-MoleculeFeatures-IconContainer').html())
      active_class: @getMolFeatureDetails(property, 0)
      data_icon: @getMolFeatureDetails(property, 1)
      tooltip: @getMolFeatureDetails(property, 2)
      tooltip_position: @getMolFeatureDetails(property, 3)
      icon_class: @getMolFeatureDetails(property, 4)

  getMolFeatureDetails: (feature, position) ->
    if feature == 'molecule_type' and @model.get('natural_product') == '1'
      @molFeatures[feature]['Natural product'][position]
    else if feature == 'molecule_type' and @model.get('polymer_flag') == true
      @molFeatures[feature]['Small molecule polymer'][position]
    else
      return @molFeatures[feature][@model.get(feature)][position]

  # active class,filename, tooltip, mobile description, tooltip position
  molFeatures:
    'molecule_type':
      'Small molecule': ['active', 'l', 'Drug Type: Synthetic Small Molecule','top', 'icon-chembl']
      'Natural product': ['active', 'P', 'Drug Type: natural product','top', 'icon-species']
      'Small molecule polymer': ['active', 'A', 'Drug Type: small molecule polymer','top', 'icon-species']
      'Antibody': ['active', 'a', 'Molecule Type: Antibody', 'top', 'icon-chembl']
      'Enzyme': ['active', 'e', 'Molecule Type: Enzyme', 'top', 'icon-chembl']
      'Oligosaccharide': ['active', 'A', 'Molecule Type: Oligosaccharide', 'top', 'icon-species']
      'Protein': ['active', 'A', 'Molecule Type: Oligopeptide', 'top', 'icon-species']
      'Oligonucleotide': ['active', 'A', 'Molecule Type: Oligonucleotide', 'top', 'icon-species']
      'Cell': ['active', 'A', 'Drug Type: Cell Based', 'top', 'icon-species']
      'Unknown': ['active', '?', 'Drug Type: Unknown', 'top', 'icon-generic']
      'Unclassified': ['active', '?', 'Drug Type: Unclassified', 'top', 'icon-generic']
    'first_in_class':
      '-1': ['', 'r', 'First in Class: Undefined', 'top', 'icon-chembl']
      '0': ['', 'r', 'First in Class: No', 'top', 'icon-chembl']
      '1': ['active', 'r', 'First in Class: Yes', 'top', 'icon-chembl']
    'chirality':
      '-1': ['', '3', 'Chirality: Undefined', 'top', 'icon-chembl']
      '0': ['active', '3', 'Chirality: Racemic Mixture', 'top', 'icon-chembl']
      '1': ['active', 'o', 'Chirality: Single Stereoisomer', 'top', 'icon-chembl']
      '2': ['', 'o', 'Chirality: Achiral Molecule', 'top', 'icon-chembl']
    'prodrug':
      '-1': ['', 'c', 'Prodrug: Undefined', 'top', 'icon-chembl'],
      '0': ['', 'c', 'Prodrug: No', 'top', 'icon-chembl']
      '1': ['active', 'c', 'Prodrug: Yes',  'top', 'icon-chembl']
    'oral':
      'true': ['active', 'u', 'Oral: Yes', 'bottom', 'icon-chembl']
      'false': ['', 'u', 'Oral: No', 'bottom', 'icon-chembl']
    'parenteral':
      'true': ['active', 's', 'Parenteral: Yes', 'bottom', 'icon-chembl']
      'false': ['', 's', 'Parenteral: No', 'bottom', 'icon-chembl']
    'topical':
      'true': ['active', 'm', 'Topical: Yes', 'bottom', 'icon-chembl']
      'false': ['', 'm', 'Topical: No', 'bottom', 'icon-chembl']
    'black_box_warning':
      '0': ['', 'b', 'Black Box: No', 'bottom', 'icon-chembl']
      '1': ['active', 'b', 'Black Box: Yes', 'bottom', 'icon-chembl']
    'availability_type':
      '-1': ['', '1', 'Availability: Undefined', 'bottom', 'icon-chembl']
      '0': ['active', '2', 'Availability: Discontinued', 'bottom', 'icon-chembl']
      '1': ['active', '1', 'Availability: Prescription Only', 'bottom', 'icon-chembl']
      '2': ['active', 't', 'Availability: Over the Counter', 'bottom', 'icon-chembl']
    'ro5':
      'true': ['active', '5', 'Rule Of Five: Yes', 'top', 'icon-chembl']
      'false': ['', '5', 'Rule Of Five: No', 'top', 'icon-chembl']
