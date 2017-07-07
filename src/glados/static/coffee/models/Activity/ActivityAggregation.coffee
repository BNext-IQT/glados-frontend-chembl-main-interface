glados.useNameSpace 'glados.models.Activity',
  ActivityAggregation: Backbone.Model.extend
    initialize: -> console.log 'init ActivityAggregation'

glados.models.Activity.ActivityAggregation.COLUMNS = {
  BIOACTIVITIES_NUMBER: {
    'name_to_show': 'Activity Count'
    'comparator': 'activity_count'
    'sort_disabled': false
    'is_sorting': 0
    'sort_class': 'fa-sort'
  }
  PCHEMBL_VALUE_AVG: {
    'name_to_show': 'pChEMBL Avg'
    'comparator': 'pchembl_value_avg'
    'sort_disabled': false
    'is_sorting': 0
    'sort_class': 'fa-sort'
    'format_as_number': true
    'num_decimals': 2
  }
}

glados.models.Activity.ActivityAggregation.COLUMNS_SETTINGS = {
  RESULTS_LIST_TABLE: [
    glados.models.Activity.ActivityAggregation.COLUMNS.BIOACTIVITIES_NUMBER
    glados.models.Activity.ActivityAggregation.COLUMNS.PCHEMBL_VALUE_AVG
  ]
}

glados.models.Activity.ActivityAggregation.MINI_REPORT_CARD =
  LOADING_TEMPLATE: 'Handlebars-Common-MiniRepCardPreloader'
  TEMPLATE: 'Handlebars-Common-MiniReportCard'
  COLUMNS: glados.models.Activity.ActivityAggregation.COLUMNS_SETTINGS.RESULTS_LIST_TABLE