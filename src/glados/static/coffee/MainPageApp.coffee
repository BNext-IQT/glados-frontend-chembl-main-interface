# Class in charge of rendering the index page of the ChEMBL web ui
class MainPageApp

  # --------------------------------------------------------------------------------------------------------------------
  # Initialization
  # --------------------------------------------------------------------------------------------------------------------

  @init = ->
    glados.apps.Main.MainGladosApp.hideMainSplashScreen()
    MainPageApp.initCentralCarousel()

    #   Init database summary
    databaseInfo = new glados.models.MainPage.DatabaseSummaryInfo()
    new glados.views.MainPage.DatabaseSummaryView
      model: databaseInfo
      el: $('.BCK-Database-summary-info')
    databaseInfo.fetch()

    #   Init tweet box
    tweetsList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewTweetsList()
    tweetsList.initURL()
    $tweetsElem = $('.BCK-Tweets-container')
    glados.views.PaginatedViews.PaginatedViewFactory.getNewInfinitePaginatedView(tweetsList, $tweetsElem, 'do-repaint')
    tweetsList.fetch()

  # ---------------- Aggregation -------------- #
  @getDocumentsPerYearAgg = (defaultInterval = 1) ->
    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.QUERY_STRING
      query_string_template: '*'
      template_data: {}

    aggsConfig =
      aggs:
        documentsPerYear:
          type: glados.models.Aggregations.Aggregation.AggTypes.HISTOGRAM
          field: 'year'
          default_interval_size: defaultInterval
          min_interval_size: 1
          max_interval_size: 10
          bucket_key_parse_function: (key) -> key.replace(/\.0/i, '')
          aggs:
            split_series_agg:
              type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
              field: 'journal'
              size: 10
              bucket_links:
                bucket_filter_template: 'year:{{year}} AND journal:("{{bucket_key}}"' +
                  '{{#each extra_buckets}} OR "{{this}}"{{/each}})'
                template_data:
                  year: 'BUCKET.parsed_parent_key'
                  bucket_key: 'BUCKET.key'
                  extra_buckets: 'EXTRA_BUCKETS.key'

                link_generator: Document.getDocumentsListURL

    allDocumentsByYear = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.DOCUMENT_INDEX_URL
      query_config: queryConfig
      aggs_config: aggsConfig

    return allDocumentsByYear

  @getMaxPhaseForDiseaseAgg = () ->
    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.QUERY_STRING
      query_string_template: '_metadata.drug.is_drug:true'
      template_data: {}

    aggsConfig =
      aggs:
        maxPhaseForDisease:
          type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
          field: 'max_phase'
          size: 5
          bucket_links:
            bucket_filter_template: '_metadata.drug.is_drug:true AND ' +
              'max_phase:{{bucket_key}}'
            template_data:
              bucket_key: 'BUCKET.key'

            link_generator: Compound.getCompoundsListURL
          aggs:
            split_series_agg:
              type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
              field: '_metadata.drug_indications.efo_term'
              size: 12
              bucket_links:
                bucket_filter_template: '_metadata.drug.is_drug:true AND ' +
                  'max_phase :{{max_phase}} AND _metadata.drug_indications.efo_term:("{{bucket_key}}"' +
                  '{{#each extra_buckets}} OR "{{this}}"{{/each}})'
                template_data:
                  max_phase: 'BUCKET.parent_key'
                  bucket_key: 'BUCKET.key'
                  extra_buckets: 'EXTRA_BUCKETS.key'

                link_generator: Compound.getCompoundsListURL

    MaxPhaseForDisease = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.COMPOUND_INDEX_URL
      query_config: queryConfig
      aggs_config: aggsConfig

    return MaxPhaseForDisease

  @initMaxPhaseForDisease = ->
    maxPhaseForDisease = MainPageApp.getMaxPhaseForDiseaseAgg()
    maxPhaseProp = glados.models.visualisation.PropertiesFactory.getPropertyConfigFor('Compound', 'MAX_PHASE', true)
    diseaseClassProp = glados.models.visualisation.PropertiesFactory.getPropertyConfigFor('Compound', 'DISEASE')

    pieConfig =
      side_legend: true
      x_axis_prop_name: 'maxPhaseForDisease'
      split_series_prop_name: 'split_series_agg'
      title: 'Max Phase for Disease'
      max_categories: 5
      stacked_donut: true
      stacked_levels: 2
      hide_title: true
      properties:
        max_phase: maxPhaseProp
        disease_class: diseaseClassProp
      initial_property_x: 'max_phase'
      initial_property_z: 'disease_class'
      title_link_url: Drug.getDrugsListURL()

    config =
      pie_config: pieConfig
      is_outside_an_entity_report_card: true
      embed_url: "#{glados.Settings.GLADOS_BASE_URL_FULL}embed/#max_phase_for_disease"
      link_to_all:
        link_text: 'See all drug Compounds in ChEMBL'
        url: Drug.getDrugsListURL()

    new glados.views.ReportCards.PieInCardView
      el: $('#MaxPhaseForDisease')
      model: maxPhaseForDisease
      config: config
      report_card_app: @

    maxPhaseForDisease.fetch()

  @getTargetsTreeAgg = ->
    queryConfig =
      type: glados.models.Aggregations.Aggregation.QueryTypes.QUERY_STRING
      query_string_template: '*'
      template_data: {}

    aggsConfig =
      aggs:
        l1_class:
          type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
          field: '_metadata.protein_classification.l1'
          size: 100
          bucket_links:
            bucket_filter_template: '_metadata.protein_classification.l1:("{{bucket_key}}")'
            template_data:
              bucket_key: 'BUCKET.key'
            link_generator: Target.getTargetsListURL
          aggs:
            l2_class:
              type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
              field: '_metadata.protein_classification.l2'
              size: 100
              bucket_links:
                bucket_filter_template: '_metadata.protein_classification.l2:("{{bucket_key}}")'
                template_data:
                  bucket_key: 'BUCKET.key'
                link_generator: Target.getTargetsListURL
              aggs:
                l3_class:
                  type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
                  field: '_metadata.protein_classification.l3'
                  size: 100
                  bucket_links:
                    bucket_filter_template: '_metadata.protein_classification.l3:("{{bucket_key}}")'
                    template_data:
                      bucket_key: 'BUCKET.key'
                    link_generator: Target.getTargetsListURL
                  aggs:
                    l4_class:
                      type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
                      field: '_metadata.protein_classification.l4'
                      size: 100
                      bucket_links:
                        bucket_filter_template: '_metadata.protein_classification.l4:("{{bucket_key}}")'
                        template_data:
                          bucket_key: 'BUCKET.key'
                        link_generator: Target.getTargetsListURL
                      aggs:
                        l5_class:
                          type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
                          field: '_metadata.protein_classification.l5'
                          size: 100
                          bucket_links:
                            bucket_filter_template: '_metadata.protein_classification.l5:("{{bucket_key}}")'
                            template_data:
                              bucket_key: 'BUCKET.key'
                            link_generator: Target.getTargetsListURL
                          aggs:
                            l6_class:
                              type: glados.models.Aggregations.Aggregation.AggTypes.TERMS
                              field: '_metadata.protein_classification.l6'
                              size: 100
                              bucket_links:
                                bucket_filter_template: '_metadata.protein_classification.l6:("{{bucket_key}}")'
                                template_data:
                                  bucket_key: 'BUCKET.key'
                                link_generator: Target.getTargetsListURL


    targetsTreeAgg = new glados.models.Aggregations.Aggregation
      index_url: glados.models.Aggregations.Aggregation.TARGET_INDEX_URL
      query_config: queryConfig
      aggs_config: aggsConfig

    return targetsTreeAgg


  @initPapersPerYear = ->
    allDocumentsByYear = MainPageApp.getDocumentsPerYearAgg()
    yearProp = glados.models.visualisation.PropertiesFactory.getPropertyConfigFor('DocumentAggregation',
      'YEAR')
    journalNameProp = glados.models.visualisation.PropertiesFactory.getPropertyConfigFor('DocumentAggregation',
      'JOURNAL_NAME')
    barsColourScale = journalNameProp.colourScale

    histogramConfig =
      bars_colour_scale: barsColourScale
      stacked_histogram: true
      rotate_x_axis_if_needed: false
      hide_x_axis_title: true
      legend_vertical: true
      big_size: true
      paint_axes_selectors: true
      properties:
        year: yearProp
        journal: journalNameProp
      initial_property_x: 'year'
      initial_property_z: 'journal'
      x_axis_options: ['count']
      x_axis_min_columns: 1
      x_axis_max_columns: 40
      x_axis_initial_num_columns: 40
      x_axis_prop_name: 'documentsPerYear'
      title: 'Documents by Year'
      title_link_url: Document.getDocumentsListURL()
      max_z_categories: 7
      title_link_url: Document.getDocumentsListURL()

    config =
      histogram_config: histogramConfig
      is_outside_an_entity_report_card: true
      embed_url: "#{glados.Settings.GLADOS_BASE_URL_FULL}embed/#documents_by_year_histogram"

    new glados.views.ReportCards.HistogramInCardView
      el: $('#PapersPerYearHistogram')
      model: allDocumentsByYear
      config: config
      report_card_app: @

    allDocumentsByYear.fetch()

  @initTargetsVisualisation = ->
    targetHierarchy = TargetBrowserApp.initTargetHierarchyTree()

    config =
      is_outside_an_entity_report_card: true
      embed_url: "#{glados.Settings.GLADOS_BASE_URL_FULL}embed/#targets_by_protein_class"
      view_class: BrowseTargetAsCirclesView

    targetsHierarchyAgg = MainPageApp.getTargetsTreeAgg()
    targetsHierarchyAgg.fetch()
    targetBrowserView = TargetBrowserApp.initBrowserAsCircles(targetHierarchy, $('#BCK-TargetBrowserAsCircles'))
    targetHierarchy.fetch()

    new glados.views.ReportCards.VisualisationInCardView
      el: $('#BCK-TargetBrowserAsCircles')
      model: targetHierarchy
      config: config
      report_card_app: @

    targetHierarchy.fetch()

  @initCentralCarousel = ->
    $carouselContainer = $('.carousel-wrapper')
    $linksCarousel = $('.links-carousel')

    $carouselContainer.slick {
      asNavFor: $linksCarousel
      arrows: true
      autoplay: false
      autoplaySpeed: 3000
      dots: true
    }


    $linksCarousel.slick {
      useCSS: false
      fade: true
      arrows: false
      dots: false
    }

    MainPageApp.initPapersPerYear()
    MainPageApp.initMaxPhaseForDisease()
    MainPageApp.initTargetsVisualisation()







