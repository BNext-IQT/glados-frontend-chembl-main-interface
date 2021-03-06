glados.useNameSpace 'glados.views.Compound',
  DeferredStructureView: Backbone.View.extend
    initialize: ->

      @showSpecialStructure = arguments[0].show_special_structure
      @showSpecialStructure ?= false

      @initPreloader()
      @initErrorMessagesContainer()
      @$image = $(@el).find('img.BCK-main-image')
      @$specialStructImage = $(@el).find('img.BCK-specialStruct-image')

      if @model.get('enable_similarity_map')

        @initSimilarityMode()
        @model.on glados.Events.Compound.SIMILARITY_MAP_READY, @showCorrectImage, @
        @model.on glados.Events.Compound.SIMILARITY_MAP_ERROR, @showCorrectImage, @

      if @model.get('enable_substructure_highlighting')

        @initSubstructureHighlightMode()
        @model.on glados.Events.Compound.STRUCTURE_HIGHLIGHT_ERROR, @showCorrectImage, @
        @model.on glados.Events.Compound.STRUCTURE_HIGHLIGHT_READY, @showCorrectImage, @

    #-------------------------------------------------------------------------------------------------------------------
    # Mode initialisation
    #-------------------------------------------------------------------------------------------------------------------
    initSimilarityMode: ->
      @loadingStructurePropName = 'loading_similarity_map'
      @base64ImgPropName = 'similarity_map_base64_img'

    initSubstructureHighlightMode: ->

      @loadingStructurePropName = 'loading_substructure_highlight'
      @base64ImgPropName = 'substructure_highlight_base64_img'

    #-------------------------------------------------------------------------------------------------------------------
    # Structure show
    #-------------------------------------------------------------------------------------------------------------------
    renderSimilarityMap: ->
      @$specialStructImage.attr('src', @model.get(@base64ImgPropName))

    #-------------------------------------------------------------------------------------------------------------------
    # General
    #-------------------------------------------------------------------------------------------------------------------
    initPreloader: ->

      @$preloaderContainer = $(@el).find('.BCK-preloader')
      @$preloaderContainer.html glados.Utils.getContentFromTemplate('Handlebars-Common-MiniRepCardPreloader')
      @$preloaderContainer.hide()

    showPreloader: ->

      @$preloaderContainer.show()
      @hideAllImages()

    hidePreloader: -> @$preloaderContainer.hide()

    initErrorMessagesContainer: -> @$errorMessagesContainer = $(@el).find('.BCK-error-messages-container')

    renderLoadingError: ->

      jqXHR = @model.get('reference_smiles_error_jqxhr')
      @$errorMessagesContainer.html glados.Utils.ErrorMessages.getErrorImageContent(jqXHR)

    showLoadingError: ->

      @hidePreloader()
      @hideAllImages()
      @$errorMessagesContainer.show()

    hideErrorMessagesContainer: -> @$errorMessagesContainer.hide()
    #-------------------------------------------------------------------------------------------------------------------
    # Images Handling
    #-------------------------------------------------------------------------------------------------------------------
    hideAllImages: ->

      @$image.hide()
      @$specialStructImage.hide()

    # Here I read the status of the object and act accordingly.
    showCorrectImage: ->

      if @showSpecialStructure
        if @model.get(@loadingStructurePropName)
          @showPreloader()
        else if @model.get('reference_smiles_error')
          @renderLoadingError()
          @showLoadingError()
        else
          @showSpecialStructureImage()
      else
        @showNormalImage()

    showNormalImage: ->

      @$specialStructImage.hide()
      @$image.show()
      @hidePreloader()
      @hideErrorMessagesContainer()

    showSpecialStructureImage: ->

      @renderSimilarityMap()
      @$image.hide()
      @$specialStructImage.show()
      @hidePreloader()
      @hideErrorMessagesContainer()

    setShowSpecialStructure: (show) -> @showSpecialStructure = show

