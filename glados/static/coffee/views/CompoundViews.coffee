# View that renders the Compound Name and Classification section
# from the compound report card
CompoundNameClassificationView = Backbone.View.extend

  initialize: ->
    @model.on 'change', @.render, @
    @model.on 'error', @.showErrorCard, @

  showErrorCard: ->
    $(@el).children('.card-preolader-to-hide').hide()
    $(@el).children('.card-load-error').show()

  render: ->
    $(@el).children('.card-preolader-to-hide').hide()
    $(@el).children(':not(.card-preolader-to-hide, .card-load-error)').show()

    attributes = @model.toJSON()
    @renderTitle()
    @renderPrefName()
    @renderMaxPhase()
    @renderMolFormula()
    @renderImage()
    @renderSynonymsAndTradeNames()

    # this is required to render correctly the molecular formulas.
    # it comes from the easychem.js library
    ChemJQ.autoCompile()

  renderTitle: ->
    $(@el).find('#Bck-CHEMBL_ID').text(@model.get('molecule_chembl_id'))

  renderPrefName: ->
    $(@el).find('#Bck-PREF_NAME').text(@model.get('pref_name'))

  renderMaxPhase: ->
    phase = @model.get('max_phase')
    phase_class = 'comp-phase-' + phase

    show_phase = phase != 0

    description = switch
      when phase == 1 then 'Phase I'
      when phase == 2 then 'Phase II'
      when phase == 3 then 'Phase III'
      when phase == 4 then 'Approved'
      else
        'Undefined'

    tooltip_text = switch
      when phase == 0 then 'Phase 0: Exploratory study involving very limited human exposure to the drug, with no ' +
        'therapeutic or diagnostic goals (for example, screening studies, microdose studies)'
      when phase == 1 then 'Phase 1: Studies that are usually conducted with healthy volunteers and that emphasize ' +
        'safety. The goal is to find out what the drug\'s most frequent and serious adverse events are and, often, ' +
        'how the drug is metabolized and excreted.'
      when phase == 2 then 'Phase 2: Studies that gather preliminary data on effectiveness (whether the drug works ' +
        'in people who have a certain disease or condition). For example, participants receiving the drug may be ' +
        'compared to similar participants receiving a different treatment, usually an inactive substance, called a ' +
        'placebo, or a different drug. Safety continues to be evaluated, and short-term adverse events are studied.'
      when phase == 3 then 'Phase 3: Studies that gather more information about safety and effectiveness by studying ' +
        'different populations and different dosages and by using the drug in combination with other drugs.'
      when phase == 4 then 'Phase 4: Studies occurring after FDA has approved a drug for marketing. These including ' +
        'postmarket requirement and commitment studies that are required of or agreed to by the study sponsor. These ' +
        'studies gather additional information about a drug\'s safety, efficacy, or optimal use.'
      else
        'Undefined'

    source =
      '<span class="{{class}}"> {{text}} </span>' +
        '{{#if show_phase}}' +
        '  <span class="{{class}}"> {{desc}} </span>' +
        '{{/if}}' +
        '<span >' +
        ' <i class="fa fa-question hoverable tooltipped" data-tooltip="{{tooltip}}" data-position="top"> </i></a>' +
        '</span>'


    template = Handlebars.compile(source)
    rendered = template
      class: phase_class
      text: phase
      desc: description
      show_phase: show_phase
      tooltip: tooltip_text

    $(@el).find('#Bck-MAX_PHASE').html(rendered)
    #Initialize materialize tooltip
    $(@el).find('#Bck-MAX_PHASE').find('.tooltipped').tooltip()

  renderMolFormula: ->
    $(@el).find('#Bck-MOLFORMULA').text(@model.get('molecule_properties')['full_molformula'])

  renderImage: ->
    img_url = 'https://www.ebi.ac.uk/chembl/api/data/image/' + @model.get('molecule_chembl_id')
    $(@el).find('#Bck-COMP_IMG').attr('src', img_url)

  renderSynonymsAndTradeNames: ->
    all_syns = @model.get('molecule_synonyms')
    unique_synonyms = new Set()
    trade_names = new Set()

    $.each all_syns, (index, value) ->
      if value.syn_type == 'TRADE_NAME'
        trade_names.add(value.synonyms)

      unique_synonyms.add(value.synonyms)

    synonyms_source = '{{#each items}}' +
      ' <span class="CNC-chip-syn">{{ this }}</span> ' +
      '{{/each}}'

    syn_rendered = Handlebars.compile(synonyms_source)
      items: Array.from(unique_synonyms)

    $(@el).find('#CompNameClass-synonyms').html(syn_rendered)

    tradenames_source = '{{#each items}}' +
      ' <span class="CNC-chip-tn">{{ this }}</span> ' +
      '{{/each}}'

    tn_rendered = Handlebars.compile(tradenames_source)
      items: Array.from(trade_names)

    $(@el).find('#CompNameClass-tradenames').html(tn_rendered)










