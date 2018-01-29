# this view is in charge of showing a collection of elements as a pie chart
PieView = Backbone.View.extend(ResponsiviseViewExt).extend

  initialize: ->

    @config = arguments[0].config
    @xAxisAggName = @config.x_axis_prop_name
    @model.on 'change', @render, @
    @$vis_elem = $(@el).find('.BCK-pie-container')
    updateViewProxy = @setUpResponsiveRender()

  showNoDataFoundMessage: ->


    $visualisationMessages = $(@el).find('.BCK-VisualisationMessages')

    if @config.custom_empty_message?
      emptyMessage = @config.custom_empty_message
    else
      emptyMessage = "No data available. #{@config.title}"

    glados.Utils.fillContentForElement $visualisationMessages,
      msg: emptyMessage

    $mainPieContainer = $(@el)
    $mainPieContainer.addClass('pie-with-error')


  render: ->

    if @model.get('state') == glados.models.Aggregations.Aggregation.States.NO_DATA_FOUND_STATE
      @showNoDataFoundMessage()
      return

    if @model.get('state') != glados.models.Aggregations.Aggregation.States.INITIAL_STATE
      return

    buckets =  @model.get('bucket_data')[@xAxisAggName].buckets
    if buckets.length == 0
      @showNoDataFoundMessage()
      return


    $titleContainer = $(@el).find('.BCK-pie-title')
    glados.Utils.fillContentForElement $titleContainer,
      title: @config.title

    values = []
    labels = []

    maxCategories = @config.max_categories
    if buckets.length > maxCategories
      buckets = glados.Utils.Buckets.mergeBuckets(buckets, maxCategories, @model, @config.x_axis_prop_name)

    bucketsIndex = _.indexBy(buckets, 'key')
    for bucket in buckets
      values.push bucket.doc_count
      labels.push bucket.key

      #define color palette
      col = [
        glados.Settings.PIECHARTS.TEAL1,
        glados.Settings.PIECHARTS.GREEN1,
        glados.Settings.PIECHARTS.GREEN2,
        glados.Settings.PIECHARTS.AMBER,
        glados.Settings.PIECHARTS.ORANGE,
        glados.Settings.PIECHARTS.RED,
        glados.Settings.PIECHARTS.PINK,
        glados.Settings.PIECHARTS.PURPLE,
        glados.Settings.PIECHARTS.BLUE1,
        glados.Settings.PIECHARTS.BLUE2
      ]


    data1 =
      values: values
      labels: labels
      type: 'pie'
      textinfo:'value'
      marker:
        colors: col


    data = [data1]
    width = @$vis_elem.width()
    minWidth = 400
    if width < minWidth
      width = minWidth

    layout =
      height: width * (3/5)
      width: width
      margin:
        l: 5
        r: 5
        b: 5
        t: 40
        pad: 4
      legend:
        orientation: 'h'
      font:
        family: "ChEMBL_HelveticaNeueLTPRo"


    pieDiv = @$vis_elem.get(0)
    Plotly.newPlot pieDiv, data, layout

    thisView = @
    pieDiv.on('plotly_click', (eventInfo) ->
      clickedKey = eventInfo.points[0].label
      link = bucketsIndex[clickedKey].link
      window.open(link)
    )