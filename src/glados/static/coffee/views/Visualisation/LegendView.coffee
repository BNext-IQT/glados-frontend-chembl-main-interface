# this view is in charge of painting legends
LegendView = Backbone.View.extend(ResponsiviseViewExt).extend

  LEGEND_HEIGHT: 100
  LEGEND_RECT_HEIGHT: 20

  initialize: ->
    @$vis_elem = $(@el)
    updateViewProxy = @setUpResponsiveRender()
    @render()
    @model.on(glados.Events.Legend.VALUE_SELECTED, @valueSelectedHandler, @)

  clearLegend: -> $(@el).empty()
  addExtraCss: ->
    $(@el).find('line, path').css('fill', 'none')

  valueSelectedHandler: (value) ->
    rectClassSelector = '.legend-rect-' + value
    d3.select($(@el).find(rectClassSelector)[0])
      .style('stroke', glados.Settings.VISUALISATION_SELECTED)
      .attr('data-is-selected', true)

  render: ->

    @clearLegend()
    console.log 'RENDER LEGEND!'
    elemWidth = $(@el).width()
    horizontalPadding = 10
    @legendWidth = 0.4 * elemWidth
    legendHeight = @LEGEND_HEIGHT

    legendContainer = d3.select($(@el).get(0))
    legendSVG = legendContainer.append('svg')
      .attr('width', @legendWidth + 2 * horizontalPadding )
      .attr('height', legendHeight )
    legendG = legendSVG.append('g')
      .attr("transform", "translate(" + horizontalPadding + "," + (legendHeight - 30) + ")")

    legendSVG.append('text')
        .text(@model.get('property').label)
        .attr("class", 'plot-colour-legend-title')
    # center legend title
    textWidth = d3.select('.plot-colour-legend-title').node().getBBox().width
    xTrans = (@legendWidth - textWidth) / 2
    legendSVG.select('.plot-colour-legend-title')
      .attr("transform", "translate(" + xTrans + ", 35)")

    if @model.isDiscrete()
      @paintDiscreteLegend(legendG)

    @addExtraCss()

  paintDiscreteLegend: (legendG) ->

    rectanglePadding = 1
    getXInLegendFor = d3.scale.ordinal()
      .domain( @model.get('domain') )
      .rangeBands([0, @legendWidth])

    legendAxis = d3.svg.axis()
      .scale(getXInLegendFor)
      .orient("bottom")

    getColourFor = d3.scale.ordinal()
        .domain( @model.get('domain') )
        .range( @model.get('colour-range') )

    legendG.selectAll('rect')
      .data(getXInLegendFor.domain())
      .enter().append('rect')
      .attr('class', (d) -> 'legend-rect-' + d)
      .attr('height', @LEGEND_RECT_HEIGHT)
      .attr('width', getXInLegendFor.rangeBand() - rectanglePadding)
      .attr('x', (d) -> getXInLegendFor d)
      .attr('y', -@LEGEND_RECT_HEIGHT)
      .attr('fill', (d) -> getColourFor d)
      .style('stroke-width', 2)
      .classed('legend-rect', true)
      .on('click', $.proxy(@clickRectangle, @))

    legendG.call(legendAxis)

  clickRectangle: (d) ->
    @model.selectByPropertyValue(d)



