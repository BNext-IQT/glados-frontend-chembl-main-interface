glados.useNameSpace 'glados.views.MainPage',
  VisualisationsWithCaptionsView: Backbone.View.extend(ResponsiviseViewExt).extend

    initialize: ->

      @carouselInitialised = false
      @setUpResponsiveRender()
      @render()

    render: ->

      if glados.getScreenType() != glados.Settings.SMALL_SCREEN

        if not @carouselInitialised

          @initCarousel()
          @carouselInitialised = true

    initCarousel: ->

      $carouselContainer = $(@el).find('.BCK-carousel-wrapper')
      $captionsCarousel = $(@el).find('.BCK-carousel-captions')

      visualisationsConfig = glados.views.MainPage.VisualisationsWithCaptionsView.VISUALISATIONS_CONFIG
      numSlides = _.keys(visualisationsConfig).length
      initialSlide = Math.floor(Math.random() * numSlides)

      glados.Utils.fillContentForElement $carouselContainer,
        visualisations_ids: ({id:i, is_caption: false} for i in [0..numSlides-1])

      glados.Utils.fillContentForElement $captionsCarousel,
        visualisations_ids: ({id:i, is_caption: true} for i in [0..numSlides-1])

      $carouselContainer.slick {
        asNavFor: $captionsCarousel
        arrows: true
        dots: true
        initialSlide: initialSlide
        infinite: false
      }

      $captionsCarousel.slick {
        useCSS: false
        fade: true
        arrows: false
        dots: false
        initialSlide: initialSlide
        infinite: false
      }

      thisView = @
      $carouselContainer.on 'setPosition', (event, slick) -> thisView.initSlide(slick.currentSlide)
      @initSlide(initialSlide)

    initSlide: (slideNumber) ->

      $vizContainer = $(@el).find("[data-carousel-item-id='CarouselVisualisation#{slideNumber}']")
      $captionContainer = $(@el).find("[data-carousel-item-id='CarouselCaption#{slideNumber}']")

      wasInitialised = $vizContainer.attr('data-initialised')

      if wasInitialised != 'yes'

        visualisationConfig = glados.views.MainPage.VisualisationsWithCaptionsView.VISUALISATIONS_CONFIG[slideNumber]

        caption = visualisationConfig.caption
        linkTitle = visualisationConfig.link_title
        LinkFunction = visualisationConfig.link_url_function
        visTitle = visualisationConfig.vis_title

        templateParams =
          caption: caption
          link_title: linkTitle
          link_url: LinkFunction()
          vis_title: visTitle
          vis_id: slideNumber
        glados.Utils.fillContentForElement($captionContainer, templateParams, 'Handlebars-Carousel-items-caption')

        templateSourceURL = glados.views.MainPage.VisualisationsWithCaptionsView.VISUALISATIONS_HB_SOURCES
        templateID = visualisationConfig.template_id
        loadPromise = glados.Utils.loadTemplateAndFillContentForElement(templateSourceURL, templateID, $vizContainer)

        thisView = @
        loadPromise.done ->
          initFunction = visualisationConfig.init_function
          if visualisationConfig.uses_browse_button_dynamically
            $browseButtonContainer =
              $(thisView.el).find(".BCK-browse-button[data-viz-item-id='Visualisation#{slideNumber}']")
            initFunction($browseButtonContainer)
          else
            initFunction()

        $vizContainer.attr('data-initialised', 'yes')

glados.views.MainPage.VisualisationsWithCaptionsView.VISUALISATIONS_HB_SOURCES =
  "#{glados.Settings.GLADOS_BASE_PATH_REL}handlebars/visualisation_sources"

glados.views.MainPage.VisualisationsWithCaptionsView.VISUALISATIONS_CONFIG =
  0:
    caption: 'Caption For 0'
    template_id: 'Handlebars-Visualisations-BrowseEntitiesCircles'
    init_function: MainPageApp.initBrowseEntities
    link_title: 'Browse all ChEMBL'
    link_url_function: -> SearchModel.getSearchURL()
    vis_title: 'Explore ChEMBL'
  1:
    caption: 'Caption For 1'
    template_id: 'Handlebars-Visualisations-ZoomableSunburst'
    init_function: MainPageApp.initZoomableSunburst
    link_title: 'Browse all Targets'
    link_url_function: -> Target.getTargetsListURL()
    vis_title: 'Protein Target Classification'
    uses_browse_button_dynamically: true
  2:
    caption: 'Caption For 2'
    template_id: 'Handlebars-Visualisations-DrugsPerUsanYear'
    init_function: MainPageApp.initDrugsPerUsanYear
    link_title: 'Browse all USAN Drugs'
    link_url_function: -> Drug.getDrugsListURL('_metadata.compound_records.src_id:13')
    vis_title: 'Drugs by Max Phase and Usan Year'
  3:
    caption: 'Caption For 3'
    template_id: 'Handlebars-Visualisations-BrowseTargetsAsCircles'
    init_function: MainPageApp.initTargetsVisualisation
    link_title: 'Browse all Targets'
    link_url_function: -> Target.getTargetsListURL()
    vis_title: 'Organism Taxonomy Classification'
    uses_browse_button_dynamically: true
  4:
    caption: 'Caption For 4'
    template_id: 'Handlebars-Visualisations-MaxPhaseForDiseaseDonut'
    init_function: MainPageApp.initMaxPhaseForDisease
    link_title: 'Browse all Drugs'
    link_url_function: -> Drug.getDrugsListURL()
    vis_title: 'Drugs By Max Phase and Disease'
  5:
    caption: 'Caption For 5'
    template_id: 'Handlebars-Visualisations-DrugFirstApprovalHistogram'
    init_function: MainPageApp.initFirstApprovalByMoleculeType
    link_title: 'Browse all Approved Drugs'
    link_url_function: -> Drug.getDrugsListURL('_exists_:first_approval')
    vis_title: 'Drugs by Molecule Type and First Approval'