class AssayReportCardApp extends glados.ReportCardApp

  # -------------------------------------------------------------
  # Initialisation
  # -------------------------------------------------------------
  @init = ->

    super
    assay = AssayReportCardApp.getCurrentAssay()
    AssayReportCardApp.initAssayBasicInformation()
    AssayReportCardApp.initCurationSummary()
    AssayReportCardApp.initActivitySummary()
    AssayReportCardApp.initAssociatedCompounds()
    AssayReportCardApp.initTargetSummary()

    assay.fetch()

    $('.scrollspy').scrollSpy();
    ScrollSpyHelper.initializeScrollSpyPinner();

  # -------------------------------------------------------------
  # Specific section initialization
  # this is functions only initialize a section of the report card
  # -------------------------------------------------------------
  @initAssayBasicInformation = ->

    assay = AssayReportCardApp.getCurrentAssay()

    new AssayBasicInformationView
      model: assay
      el: $('#ABasicInformation')
      section_id: 'BasicInformation'
      section_label: 'Basic Information'
      report_card_app: @

    if GlobalVariables['EMBEDED']
      assay.fetch()

  @initCurationSummary = ->

    target = new Target
      assay_chembl_id: glados.Utils.URLS.getCurrentModelChemblID()

    new AssayCurationSummaryView
      model: target
      el: $('#ACurationSummaryCard')
      section_id: 'CurationSummary'
      section_label: 'Curation Summary'
      report_card_app: @

    target.fetchFromAssayChemblID();

  @initActivitySummary = ->

    chemblID = glados.Utils.URLS.getCurrentModelChemblID()
    bioactivities = AssayReportCardApp.getAssociatedBioactivitiesAgg(chemblID)

    pieConfig =
      x_axis_prop_name: 'types'
      title: gettext('glados_assay__associated_activities_pie_title_base') + chemblID

    viewConfig =
      pie_config: pieConfig
      resource_type: gettext('glados_entities_assay_name')
      embed_section_name: 'bioactivities'
      embed_identifier: chemblID
      link_to_all:
        link_text: 'See all bioactivities for assay ' + chemblID + ' used in this visualisation.'
        url: Activity.getActivitiesListURL('assay_chembl_id:' + chemblID)

    new glados.views.ReportCards.PieInCardView
      model: bioactivities
      el: $('#AAssociatedBioactivitiesCard')
      config: viewConfig
      section_id: 'Bioactivity'
      section_label: 'Activity Summary'
      report_card_app: @

    bioactivities.fetch()

  @initAssociatedCompounds = ->

    chemblID = glados.Utils.URLS.getCurrentModelChemblID()
    associatedCompounds = AssayReportCardApp.getAssociatedCompoundsAgg(chemblID)

    histogramConfig =
      big_size: true
      paint_axes_selectors: true
      properties:
        mwt: glados.models.visualisation.PropertiesFactory.getPropertyConfigFor('Compound', 'FULL_MWT')
        alogp: glados.models.visualisation.PropertiesFactory.getPropertyConfigFor('Compound', 'ALogP')
        psa: glados.models.visualisation.PropertiesFactory.getPropertyConfigFor('Compound', 'PSA')
      initial_property_x: 'mwt'
      x_axis_options: ['mwt', 'alogp', 'psa']
      x_axis_min_columns: 1
      x_axis_max_columns: 20
      x_axis_initial_num_columns: 10
      x_axis_prop_name: 'x_axis_agg'
      title: 'Associated Compounds for Assay ' + chemblID
      title_link_url: Compound.getCompoundsListURL('_metadata.related_assays.chembl_ids.\\*:' + chemblID)
      range_categories: true

    config =
      histogram_config: histogramConfig
      resource_type: 'Assay'
      embed_section_name: 'associated_compounds'
      embed_identifier: chemblID

    new glados.views.ReportCards.HistogramInCardView
      el: $('#AAssociatedCompoundProperties')
      model: associatedCompounds
      target_chembl_id: chemblID
      config: config
      section_id: 'CompoundSummaries'
      section_label: 'Compound Summary'
      report_card_app: @

    associatedCompounds.fetch()

  @initTargetSummary = ->

    #TODO: update when index is ready
    chemblID = glados.Utils.URLS.getCurrentModelChemblID()
    relatedTargets = AssayReportCardApp.getRelatedTargetsAgg(chemblID)

    pieConfig =
      x_axis_prop_name: 'types'
      title: gettext('glados_assay__associated_targets_pie_title_base') + chemblID

    viewConfig =
      pie_config: pieConfig
      resource_type: gettext('glados_entities_assay_name')
      embed_section_name: 'related_targets'
      embed_identifier: chemblID
      link_to_all:
        link_text: 'See all targets related to ' + chemblID + ' used in this visualisation.'
        url: Target.getTargetsListURL('_metadata.related_assays.chembl_ids.\\*:' + chemblID)

    new glados.views.ReportCards.PieInCardView
      model: relatedTargets
      el: $('#AAssociatedTargetsCard')
      config: viewConfig
      section_id: 'ProteinTargetSummaries'
      section_label: 'Target Summary'
      report_card_app: @

    relatedTargets.fetch()


  # -------------------------------------------------------------
  # Singleton
  # -------------------------------------------------------------
  @getCurrentAssay = ->

    if not @currentAssay?

      chemblID = glados.Utils.URLS.getCurrentModelChemblID()

      @currentAssay = new Assay
        assay_chembl_id: chemblID
      return @currentAssay

    else return @currentAssay

  # --------------------------------------------------------------------------------------------------------------------
  # Aggregations
  # --------------------------------------------------------------------------------------------------------------------
  @getAssociatedBioactivitiesAgg = (chemblID) ->

    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.QUERY_STRING
      query_string_template: 'assay_chembl_id:{{assay_chembl_id}}'
      template_data:
        assay_chembl_id: 'assay_chembl_id'

    aggsConfig =
      aggs:
        types:
          type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
          field: 'standard_type'
          size: 20
          bucket_links:

            bucket_filter_template: 'assay_chembl_id:{{assay_chembl_id}} ' +
                                    'AND standard_type:("{{bucket_key}}"' +
                                    '{{#each extra_buckets}} OR "{{this}}"{{/each}})'
            template_data:
              assay_chembl_id: 'assay_chembl_id'
              bucket_key: 'BUCKET.key'
              extra_buckets: 'EXTRA_BUCKETS.key'

            link_generator: Activity.getActivitiesListURL

    bioactivities = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.ACTIVITY_INDEX_URL
      query_config: queryConfig
      assay_chembl_id: chemblID
      aggs_config: aggsConfig

    return bioactivities

  @getAssociatedCompoundsAgg = (chemblID, minCols=1, maxCols=20, defaultCols=10) ->

    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.MULTIMATCH
      queryValueField: 'assay_chembl_id'
      fields: ['_metadata.related_assays.chembl_ids.*']

    aggsConfig =
      aggs:
        x_axis_agg:
          field: 'molecule_properties.full_mwt'
          type: glados.models.Aggregations.Aggregation.AggTypes.RANGE
          min_columns: minCols
          max_columns: maxCols
          num_columns: defaultCols
          bucket_links:
            bucket_filter_template: '_metadata.related_assays.chembl_ids.\\*:{{assay_chembl_id}} ' +
                                    'AND molecule_properties.full_mwt:(>={{min_val}} AND <={{max_val}})'
            template_data:
              assay_chembl_id: 'assay_chembl_id'
              min_val: 'BUCKET.from'
              max_val: 'BUCKETS.to'
            link_generator: Compound.getCompoundsListURL

    associatedCompounds = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.COMPOUND_INDEX_URL
      query_config: queryConfig
      assay_chembl_id: chemblID
      aggs_config: aggsConfig

    return associatedCompounds

  @getRelatedTargetsAgg = (chemblID) ->

    #TODO: use the target class when it the mapping is ready https://github.com/chembl/GLaDOS-es/issues/15
    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.MULTIMATCH
      queryValueField: 'assay_chembl_id'
      fields: ['_metadata.related_assays.chembl_ids.*']

    aggsConfig =
      aggs:
        types:
          type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
          field: 'target_type'
          size: 20
          bucket_links:

            bucket_filter_template: '_metadata.related_assays.chembl_ids.\\*:{{assay_chembl_id}} ' +
                                    'AND target_type:("{{bucket_key}}"' +
                                    '{{#each extra_buckets}} OR "{{this}}"{{/each}})'
            template_data:
              assay_chembl_id: 'assay_chembl_id'
              bucket_key: 'BUCKET.key'
              extra_buckets: 'EXTRA_BUCKETS.key'

            link_generator: Target.getTargetsListURL

    targetTypes = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.TARGET_INDEX_URL
      query_config: queryConfig
      assay_chembl_id: chemblID
      aggs_config: aggsConfig

    return targetTypes

  # --------------------------------------------------------------------------------------------------------------------
  # Histograms
  # --------------------------------------------------------------------------------------------------------------------
  @initMiniCompoundsHistogram = ($containerElem, chemblID) ->

    associatedCompounds = AssayReportCardApp.getAssociatedCompoundsAgg(chemblID, minCols=8,
      maxCols=8, defaultCols=8)

    config =
      max_categories: 8
      fixed_bar_width: true
      hide_title: false
      x_axis_prop_name: 'x_axis_agg'
      properties:
        mwt: glados.models.visualisation.PropertiesFactory.getPropertyConfigFor('Compound', 'FULL_MWT')
      initial_property_x: 'mwt'

    new glados.views.Visualisation.HistogramView
      model: associatedCompounds
      el: $containerElem
      config: config

    associatedCompounds.fetch()

  @initMiniHistogramFromFunctionLink = ->
    $clickedLink = $(@)

    [paramsList, constantParamsList, $containerElem] = \
    glados.views.PaginatedViews.PaginatedTable.prepareAndGetParamsFromFunctionLinkCell($clickedLink)

    histogramType = constantParamsList[0]
    chemblID = paramsList[0]

    if histogramType == 'compounds'
      AssayReportCardApp.initMiniCompoundsHistogram($containerElem, chemblID)

#    else if histogramType == 'targets'
#      CompoundReportCardApp.initMiniTargetsHistogram($containerElem, compoundChemblID)