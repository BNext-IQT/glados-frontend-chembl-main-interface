# View that renders the model data as a pie chart
# make sure google charts is loaded!
# <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
PieView = Backbone.View.extend

  drawPie: ->


    # Get context with jQuery - using jQuery's .get() method.
    ctx = $("#Bck-BioactivitySummaryChart").get(0).getContext("2d")
    #This will get the first returned node in the jQuery collection.

    data = [
      {
        value: 300
        color: '#F7464A'
        highlight: '#FF5A5E'
        label: 'Red'
      }
      {
        value: 50
        color: '#46BFBD'
        highlight: '#5AD3D1'
        label: 'Green'
      }
      {
        value: 100
        color: '#FDB45C'
        highlight: '#FFC870'
        label: 'Yellow'
      }
    ]

    options =
      scaleShowLabelBackdrop: true
      scaleBackdropColor: 'rgba(255,255,255,0.75)'
      scaleBeginAtZero: true
      scaleBackdropPaddingY: 2
      scaleBackdropPaddingX: 2
      scaleShowLine: true
      segmentShowStroke: true
      segmentStrokeColor: '#fff'
      segmentStrokeWidth: 2
      animationSteps: 100
      animationEasing: 'easeOutBounce'
      animateRotate: false
      animateScale: false
      legendTemplate: '<ul class="<%=name.toLowerCase()%>-legend"><% for (var i=0; i<segments.length; i++){%><li><span style="background-color:<%=segments[i].fillColor%>"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>'


    myPieChart = new Chart(ctx).Pie(data, options)
    lengend_div = $('#Bck-BioactivitySummaryChartLegend')
    lengend_div.html myPieChart.generateLegend()

    console.log(myPieChart.generateLegend())

  render: ->

    @drawPie()




