glados.useNameSpace 'glados.views.ReportCards',
  SectionView: CardView.extend

    events:
      'click .BCK-toggle-expand-collapse': 'toggleExpandCollapse'

    initialize: ->

      $sectionHeader = $(@el).find('.BCK-Section-header')
      glados.Utils.fillContentForElement $sectionHeader,
        title: @model.get('title')

    toggleExpandCollapse: ->

      if @model.get('expanded')
        console.log 'Collapse!'

        $icon = $(@el).find('.BCK-expand-collapse-button')
        $icon.removeClass('fa-minus')
        $icon.addClass('fa-plus')
        @model.set('expanded', false)
      else
        console.log 'Expand!!'

        $icon = $(@el).find('.BCK-expand-collapse-button')
        $icon.removeClass('fa-plus')
        $icon.addClass('fa-minus')
        @model.set('expanded', true)