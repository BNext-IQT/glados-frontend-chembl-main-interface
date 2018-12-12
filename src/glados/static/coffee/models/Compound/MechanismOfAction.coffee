glados.useNameSpace 'glados.models.Compound',
  MechanismOfAction: Backbone.Model.extend

    parse: (resp) ->
      imageFile = glados.Utils.getNestedValue(resp, 'parent_molecule._metadata.compound_generated.image_file')
      if imageFile != glados.Settings.DEFAULT_NULL_VALUE_LABEL
        resp.parent_image_url = "#{glados.Settings.STATIC_IMAGES_URL}compound_placeholders/#{imageFile}"
      else
        resp.parent_image_url = \
          "#{glados.Settings.WS_BASE_URL}image/#{resp.parent_molecule.molecule_chembl_id}.svg?engine=indigo"
      resp.molecule_link = Compound.get_report_card_url(resp.parent_molecule.molecule_chembl_id)

      resp.target_link = null
      if resp.target?
        resp.target_link = Target.get_report_card_url(resp.target.target_chembl_id)
      return resp


glados.models.Compound.MechanismOfAction.INDEX_NAME = 'chembl_mechanism_by_parent_target'

generateMechanismColumn = (columnMetadata)->
  return glados.models.paginatedCollections.ColumnsFactory.generateColumn glados.models.Compound\
    .MechanismOfAction.INDEX_NAME, columnMetadata

glados.models.Compound.MechanismOfAction.COLUMNS =
  MECH_ID: generateMechanismColumn
    comparator: 'mechanism_of_action.mec_id'
  MECHANISM_OF_ACTION: generateMechanismColumn
    comparator: 'mechanism_of_action.mechanism_of_action'
  MECHANISM_COMMENT: generateMechanismColumn
    comparator: 'mechanism_of_action.mechanism_comment'
  MECHANISM_SELECTIVITY_COMMENT: generateMechanismColumn
    comparator: 'mechanism_of_action.selectivity_comment'
  BINDING_SITE_NAME: generateMechanismColumn
    comparator: 'binding_site.site_name'
  BINDING_SITE_COMMENT: generateMechanismColumn
    comparator: 'mechanism_of_action.binding_site_comment'
  ACTION_TYPE: generateMechanismColumn
    comparator: 'mechanism_of_action.action_type'
  MAX_PHASE: generateMechanismColumn
    comparator: 'mechanism_of_action.max_phase'
  TARGET_CHEMBL_ID: generateMechanismColumn
    comparator: 'target.target_chembl_id'
    link_base:'target_link'
  TARGET_PREF_NAME: generateMechanismColumn
    comparator: 'target.pref_name'
  TARGET_TYPE: generateMechanismColumn
    comparator: 'target.target_type'
  TARGET_ORGANISM: generateMechanismColumn
    comparator: 'target.organism'
  REFERENCES: generateMechanismColumn
    comparator: 'mechanism_of_action.mechanism_refs'
    multiple_links: true
    multiple_links_function: (refs) -> ({text:r.ref_type, url:r.ref_url} for r in refs)
    sort_disabled: true
  COMPOUNDS: generateMechanismColumn
    comparator: 'mechanism_of_action._metadata.all_molecule_chembl_ids'
    multiple_links: true
    multiple_links_function: (ids) -> ({text:id, url:Compound.get_report_card_url(id)} for id in ids)
  MOLECULE_CHEMBL_ID: generateMechanismColumn
    comparator: 'parent_molecule.molecule_chembl_id'
    image_base_url: 'parent_image_url'
    link_base: 'molecule_link'
  MOLECULE_ATC_CODES: generateMechanismColumn
    name_to_show: 'ATC Classifications'
    name_to_show_short: 'ATC Class.'
    comparator: 'parent_molecule._metadata.atc_classifications'
    parse_function: (atcClassifications) ->
      codes = new Set()
      for atcClassI in atcClassifications
        if atcClassI.level4? and atcClassI.level4.length > 0
          codes.add(atcClassI.level4)
      return Array.from(codes).join(', ')
  MOLECULE_ATC_CODES_DESCRIPTION: generateMechanismColumn
    name_to_show: 'ATC Classifications Description'
    name_to_show_short: 'ATC Class. Desc.'
    comparator: 'parent_molecule._metadata.atc_classifications'
    custom_field_template: '<ul class="no-margin" style="width: 15rem; margin-left: 1rem !important;">' +
      '{{#each val}}<li style="list-style-type: circle;">{{this}}</li>{{/each}}</ul>'
    parse_function: (atcClassifications) ->
      codes = new Set()
      for atcClassI in atcClassifications
        if atcClassI.level4_description? and atcClassI.level4_description.length > 0
          codes.add(atcClassI.level4_description)
      return Array.from(codes)
  MOLECULE_FIRST_APPROVAL: generateMechanismColumn
    comparator: 'parent_molecule.first_approval'
  MOLECULE_USAN_STEM: generateMechanismColumn
    comparator: 'parent_molecule.usan_stem'
  MOLECULE_TYPE: generateMechanismColumn
    comparator: 'parent_molecule.molecule_type'
  MOLECULE_PREF_NAME: generateMechanismColumn
    comparator: 'parent_molecule.pref_name'
  MOLECULE_DRUG_SYNONYMS: _.extend(
    {}, generateMechanismColumn({comparator: 'parent_molecule._metadata.drug.drug_data.synonyms'}),
      custom_field_template: '<ul class="no-margin" style="width: 15rem; margin-left: 1rem !important;">' +
        '{{#each val}}<li style="list-style-type: circle;">{{this}}</li>{{/each}}</ul>'
      parse_function: (values) ->
        realValues = []
        for valI in values
          if valI?.trim().length > 0
            realValues.push valI.trim()
        return realValues
  )

glados.models.Compound.MechanismOfAction.ID_COLUMN = glados.models.Compound.MechanismOfAction.COLUMNS.MECH_ID

glados.models.Compound.MechanismOfAction.COLUMNS_SETTINGS =
  ALL_COLUMNS: (->
    colsList = []
    for key, value of glados.models.Compound.MechanismOfAction.COLUMNS
      colsList.push value
    return colsList
  )()
  RESULTS_LIST_TABLE: [
    glados.models.Compound.MechanismOfAction.COLUMNS.MOLECULE_CHEMBL_ID
    glados.models.Compound.MechanismOfAction.COLUMNS.MOLECULE_PREF_NAME
    glados.models.Compound.MechanismOfAction.COLUMNS.MOLECULE_DRUG_SYNONYMS
    glados.models.Compound.MechanismOfAction.COLUMNS.MOLECULE_TYPE
    glados.models.Compound.MechanismOfAction.COLUMNS.MOLECULE_FIRST_APPROVAL
    glados.models.Compound.MechanismOfAction.COLUMNS.MOLECULE_USAN_STEM
    glados.models.Compound.MechanismOfAction.COLUMNS.MOLECULE_ATC_CODES
    glados.models.Compound.MechanismOfAction.COLUMNS.MOLECULE_ATC_CODES_DESCRIPTION
    glados.models.Compound.MechanismOfAction.COLUMNS.MECHANISM_OF_ACTION
    glados.models.Compound.MechanismOfAction.COLUMNS.MECHANISM_COMMENT
    glados.models.Compound.MechanismOfAction.COLUMNS.MECHANISM_SELECTIVITY_COMMENT
    glados.models.Compound.MechanismOfAction.COLUMNS.ACTION_TYPE
    glados.models.Compound.MechanismOfAction.COLUMNS.TARGET_CHEMBL_ID
    glados.models.Compound.MechanismOfAction.COLUMNS.TARGET_PREF_NAME
    glados.models.Compound.MechanismOfAction.COLUMNS.TARGET_TYPE
    glados.models.Compound.MechanismOfAction.COLUMNS.TARGET_ORGANISM
    glados.models.Compound.MechanismOfAction.COLUMNS.BINDING_SITE_NAME
    glados.models.Compound.MechanismOfAction.COLUMNS.BINDING_SITE_COMMENT
    glados.models.Compound.MechanismOfAction.COLUMNS.MAX_PHASE
    glados.models.Compound.MechanismOfAction.COLUMNS.REFERENCES

  ]
  DOWNLOAD_COLUMNS: [
    glados.models.Compound.MechanismOfAction.COLUMNS.MOLECULE_CHEMBL_ID
    glados.models.Compound.MechanismOfAction.COLUMNS.MOLECULE_DRUG_SYNONYMS
    glados.models.Compound.MechanismOfAction.COLUMNS.ACTION_TYPE
    glados.models.Compound.MechanismOfAction.COLUMNS.MECHANISM_OF_ACTION
    glados.models.Compound.MechanismOfAction.COLUMNS.TARGET_CHEMBL_ID
    glados.models.Compound.MechanismOfAction.COLUMNS.MAX_PHASE
    glados.models.Compound.MechanismOfAction.COLUMNS.REFERENCES
  ]

glados.models.Compound.MechanismOfAction.getListURL = (filter) ->

  glados.Settings.ENTITY_BROWSERS_URL_GENERATOR
    entity: 'mechanisms_of_action'
    filter: encodeURIComponent(filter) unless not filter?

totalStr = ''
for key, column of glados.models.Compound.MechanismOfAction.COLUMNS
  totalStr += "msgid \"#{column.label_id}\"\n"
  totalStr += "msgstr \"#{column.name_to_show}\"\n\n"
  totalStr += "msgid \"#{column.label_mini_id}\"\n"
  totalStr += "msgstr \"#{column.name_to_show_short}\"\n\n"

console.error(totalStr)


glados.models.Compound.MechanismOfAction.getListURLByMoleculeChemblId = (moleculeChemblId) ->
  filterStr = "mechanism_of_action._metadata.all_molecule_chembl_ids:#{moleculeChemblId}"
  glados.models.Compound.MechanismOfAction.getListURL filterStr