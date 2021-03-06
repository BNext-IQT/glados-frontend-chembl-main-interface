glados.useNameSpace 'glados.models.paginatedCollections.esSchema',

  PropertiesConfigurationModel: Backbone.Model.extend

    initialize: ->

      @url = glados.Settings.PROPERTIES_GROUP_CONFIGURATION_URL_GENERATOR
        index_name: @get('index_name')
        group_name: @get('group_name')

    parse: (response) ->

      customEntity = @get('entity')
      parsedConfiguration = {}
      propsComparatorsSet = {} #  An object is used instead of Set to avoid browser compatibility issues.
      comparatorsForTextFilterSet = {}
      allColumns = []
      for subGroupKey, subGroup of response.properties

        parsedProperties = []
        for propertyDescription in subGroup
          parsedProperty = glados.models.paginatedCollections.ColumnsFactory2.generateColumn(propertyDescription, customEntity)
          parsedProperties.push(parsedProperty)

          if not propsComparatorsSet[parsedProperty.comparator]?
            allColumns.push(parsedProperty)

          propsComparatorsSet[parsedProperty.comparator] = parsedProperty.comparator

          canBeUsedInTextFilter = parsedProperty.type in ['string', 'object'] and parsedProperty.is_contextual != true
          if canBeUsedInTextFilter

            baseComparator = parsedProperty.comparator

            unless baseComparator.startsWith('_metadata')
              comparatorsForTextFilterSet[baseComparator] = baseComparator

            for field in ['eng_analyzed', 'std_analyzed', 'ws_analyzed', 'alphanumeric_lowercase_keyword']
              if parsedProperty.type == 'string'
                comparatorForTextFilter = "#{baseComparator}.#{field}"
              else
                comparatorForTextFilter = "#{baseComparator}.*.#{field}"

              comparatorsForTextFilterSet[comparatorForTextFilter] = comparatorForTextFilter

        if subGroupKey == 'default'
          parsedConfiguration.Default = parsedProperties
        else if subGroupKey == 'optional'
          parsedConfiguration.Additional = parsedProperties

      return {
        'parsed_configuration': parsedConfiguration
        'props_comparators_set': propsComparatorsSet
        'comparators_for_text_filter_set': comparatorsForTextFilterSet
        'all_columns': allColumns
      }
