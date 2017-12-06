Compound = Backbone.Model.extend(DownloadModelOrCollectionExt).extend

  idAttribute: 'molecule_chembl_id'
  defaults:
    fetch_from_elastic: true
  initialize: ->
    id = @get('id')
    id ?= @get('molecule_chembl_id')

    if @get('fetch_from_elastic')
      @url = glados.models.paginatedCollections.Settings.ES_BASE_URL + '/chembl_molecule/molecule/' + id
    else
      @url = glados.Settings.WS_BASE_URL + 'molecule/' + id + '.json'

    if @get('enable_similarity_map')
      @set('loading_similarity_map', true)
      @loadSimilarityMap()

      @on 'change:molecule_chembl_id', @loadSimilarityMap, @
      @on 'change:reference_smiles', @loadSimilarityMap, @
      @on 'change:reference_smiles_error', @loadSimilarityMap, @

    if @get('enable_substructure_highlighting')
      @set('loading_substructure_highlight', true)
      @loadStructureHighlight()

      @on 'change:molecule_chembl_id', @loadStructureHighlight, @
      @on 'change:reference_ctab', @loadStructureHighlight, @
      @on 'change:reference_smarts', @loadStructureHighlight, @
      @on 'change:reference_smiles_error', @loadStructureHighlight, @

  loadSimilarityMap:  ->

    if @get('reference_smiles_error')
      @set('loading_similarity_map', false)
      @trigger glados.Events.Compound.SIMILARITY_MAP_ERROR
      return

    # to start I need the smiles of the compound and the compared one
    structures = @get('molecule_structures')
    if not structures?
      return

    referenceSmiles = @get('reference_smiles')
    if not referenceSmiles?
      return

    @downloadSimilaritySVG()

  loadStructureHighlight: ->

    if @get('reference_smiles_error')
      @set('loading_substructure_highlight', false)
      @trigger glados.Events.Compound.STRUCTURE_HIGHLIGHT_ERROR
      return

    referenceSmiles = @get('reference_smiles')
    if not referenceSmiles?
      return

    referenceCTAB = @get('reference_ctab')
    if not referenceCTAB?
      return

    referenceSmarts = @get('reference_smarts')
    if not referenceSmarts?
      return

    model = @
    downloadHighlighted = ->
      model.downloadHighlightedSVG()

    @download2DSDF().then ->
      model.downloadAlignedSDF().then downloadHighlighted, downloadHighlighted

  #---------------------------------------------------------------------------------------------------------------------
  # Parsing
  #---------------------------------------------------------------------------------------------------------------------
  parse: (response) ->

    # get data when it comes from elastic
    if response._source?
      objData = response._source
    else
      objData = response

    filterForActivities = 'molecule_chembl_id:' + objData.molecule_chembl_id
    objData.activities_url = Activity.getActivitiesListURL(filterForActivities)

    # Lazy definition for sdf content retrieving
    objData.sdf_url = glados.Settings.WS_BASE_URL + 'molecule/' + objData.molecule_chembl_id + '.sdf'
    objData.sdf_promise = null
    objData.get_sdf_content_promise = ->
      if not objData.sdf_promise
        objData.sdf_promise = $.ajax(objData.sdf_url)
      return objData.sdf_promise

    # Calculate the rule of five from other properties
    if objData.molecule_properties?
      objData.ro5 = objData.molecule_properties.num_ro5_violations == 0
    else
      objData.ro5 = false

    # Computed Image and report card URL's for Compounds
    objData.structure_image = false
    if objData.structure_type == 'NONE' or objData.structure_type == 'SEQ'
      # see the cases here: https://www.ebi.ac.uk/seqdb/confluence/pages/viewpage.action?spaceKey=CHEMBL&title=ChEMBL+Interface
      # in the section Placeholder Compound Images

      if objData.molecule_properties?
        if glados.Utils.Compounds.containsMetals(objData.molecule_properties.full_molformula)
          objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/metalContaining.svg'
      else if objData.molecule_type == 'Oligosaccharide'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/oligosaccharide.svg'
      else if objData.molecule_type == 'Small molecule'

        if objData.natural_product == '1'
          objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/naturalProduct.svg'
        else if objData.polymer_flag == true
          objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/smallMolPolymer.svg'
        else
          objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/smallMolecule.svg'

      else if objData.molecule_type == 'Antibody'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/antibody.svg'
      else if objData.molecule_type == 'Protein'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/peptide.svg'
      else if objData.molecule_type == 'Oligonucleotide'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/oligonucleotide.svg'
      else if objData.molecule_type == 'Enzyme'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/enzyme.svg'
      else if objData.molecule_type == 'Cell'
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/cell.svg'
      else #if response.molecule_type == 'Unclassified' or response.molecule_type = 'Unknown' or not response.molecule_type?
        objData.image_url = glados.Settings.STATIC_IMAGES_URL + 'compound_placeholders/unknown.svg'


      #response.image_url = glados.Settings.OLD_DEFAULT_IMAGES_BASE_URL + response.molecule_chembl_id
    else
      objData.image_url = glados.Settings.WS_BASE_URL + 'image/' + objData.molecule_chembl_id + '.svg?engine=indigo'
      objData.image_url_png = glados.Settings.WS_BASE_URL + 'image/' + objData.molecule_chembl_id \
          + '.png?engine=indigo'
      objData.structure_image = true

    objData.report_card_url = Compound.get_report_card_url(objData.molecule_chembl_id )

    filterForTargets = '_metadata.related_compounds.chembl_ids.\\*:' + objData.molecule_chembl_id
    objData.targets_url = Target.getTargetsListURL(filterForTargets)

    return objData;

  #---------------------------------------------------------------------------------------------------------------------
  # Similarity
  #---------------------------------------------------------------------------------------------------------------------

  downloadSimilaritySVG: ()->
    @set
      reference_smiles_error: false
      download_similarity_map_error: false
    ,
      silent: true
    model = @
    promiseFunc = (resolve, reject)->
      referenceSmiles = model.get('reference_smiles')
      structures = model.get('molecule_structures')
      if not referenceSmiles?
        reject('Error, there is no reference SMILES PRESENT!')
        return
      if not structures?
        reject('Error, the compound does not have structures data!')
        return
      mySmiles = structures.canonical_smiles
      if not mySmiles?
        reject('Error, the compound does not have SMILES data!')
        return

      if model.get('similarity_map_base64_img')?
        resolve(model.get('similarity_map_base64_img'))
      else
        formData = new FormData()
        formData.append('file', new Blob([referenceSmiles+'\n'+mySmiles], {type: 'chemical/x-daylight-smiles'}), 'sim.smi')
#        formData.append('fingerprint', referenceSmiles)
        formData.append('format', 'svg')
        formData.append('height', '500')
        formData.append('width', '500')
        ajax_deferred = $.post
          url: Compound.SMILES_2_SIMILARITY_MAP_URL
          data: formData
          enctype: 'multipart/form-data'
          processData: false
          contentType: false
          cache: false
          converters:
            'text xml': String
        ajax_deferred.done (ajaxData)->
          model.set
            loading_similarity_map: false
            similarity_map_base64_img: 'data:image/svg+xml;base64,'+btoa(ajaxData)
            reference_smiles_error: false
            reference_smiles_error_jqxhr: undefined
          ,
            silent: true

          model.trigger glados.Events.Compound.SIMILARITY_MAP_READY
          resolve(ajaxData)
        ajax_deferred.fail (jqxhrError)->
          reject(jqxhrError)
    promise = new Promise(promiseFunc)
    promise.then null, (jqxhrError)->
      model.set
        download_similarity_map_error: true
        loading_similarity_map: false
        reference_smiles_error: true
        reference_smiles_error_jqxhr: jqxhrError
      ,
        silent: true

      model.trigger glados.Events.Compound.SIMILARITY_MAP_ERROR
    return promise

  #---------------------------------------------------------------------------------------------------------------------
  # Highlighting
  #---------------------------------------------------------------------------------------------------------------------

  downloadAlignedSDF: ()->
    @set
#      'reference_smiles_error': false
      'download_aligned_error': false
    ,
      silent: true
    model = @
    promiseFunc = (resolve, reject)->
      referenceCTAB = model.get('reference_ctab')
      sdf2DData = model.get('sdf2DData')
      if not referenceCTAB?
        reject('Error, the reference CTAB is not present!')
        return
      if not sdf2DData?
        reject('Error, the compound '+model.get('molecule_chembl_id')+' CTAB is not present!')
        return

      if model.get('aligned_sdf')?
        resolve(model.get('aligned_sdf'))
      else
        formData = new FormData()
        sdf2DData = sdf2DData+'$$$$\n'
        templateBlob = new Blob([referenceCTAB], {type: 'chemical/x-mdl-molfile'})
        ctabBlob = new Blob([sdf2DData+sdf2DData], {type: 'chemical/x-mdl-sdfile'})
        formData.append('template', templateBlob, 'pattern.mol')
        formData.append('ctab', ctabBlob, 'mcs.sdf')
        formData.append('force', 'true')
        ajax_deferred = $.post
          url: Compound.SDF_2D_ALIGN_URL
          data: formData
          enctype: 'multipart/form-data'
          processData: false
          contentType: false
          cache: false
        ajax_deferred.done (ajaxData)->
          alignedSdf = ajaxData.split('$$$$')[0]+'$$$$\n'
          model.set('aligned_sdf', alignedSdf)
          resolve(ajaxData)
        ajax_deferred.fail (jqxhrError)->
          reject(jqxhrError)
    promise = new Promise(promiseFunc)
    promise.then null, (jqxhrError)->
      console.error jqxhrError
      model.set
        'download_aligned_error': true
#        'reference_smiles_error': true
#      model.trigger glados.Events.Compound.STRUCTURE_HIGHLIGHT_ERROR
    return promise

  downloadHighlightedSVG: ()->
    @set
      'reference_smiles_error': false
      'download_highlighted_error': false
    ,
      silent: true
    model = @
    promiseFunc = (resolve, reject)->
      referenceSmarts = model.get('reference_smarts')
      # Tries to use the 2d sdf without alignment if the alignment failed
      if model.get('aligned_sdf')?
        alignedSdf = model.get('aligned_sdf')
      else
        alignedSdf = model.get('sdf2DData')
      if not referenceSmarts?
        reject('Error, the reference SMARTS is not present!')
        return
      if not alignedSdf?
        reject('Error, the compound '+model.get('molecule_chembl_id')+' ALIGNED CTAB is not present!')
        return

      if model.get('substructure_highlight_base64_img')?
        resolve(model.get('substructure_highlight_base64_img'))
      else
        formData = new FormData()
        formData.append('file', new Blob([alignedSdf], {type: 'chemical/x-mdl-molfile'}), 'aligned.mol')
        formData.append('smarts', referenceSmarts)
        formData.append('computeCoords', 0)
        formData.append('force', 'true')
        ajax_deferred = $.post
          url: Compound.SDF_2D_HIGHLIGHT_URL
          data: formData
          enctype: 'multipart/form-data'
          processData: false
          contentType: false
          cache: false
          converters:
            'text xml': String
        ajax_deferred.done (ajaxData)->
          model.set
            loading_substructure_highlight: false
            substructure_highlight_base64_img: 'data:image/svg+xml;base64,'+btoa(ajaxData)
            reference_smiles_error: false
            reference_smiles_error_jqxhr: undefined
          ,
            silent: true
          model.trigger glados.Events.Compound.STRUCTURE_HIGHLIGHT_READY
          resolve(ajaxData)
        ajax_deferred.fail (jqxhrError)->
          reject(jqxhrError)
    promise = new Promise(promiseFunc)
    promise.then null, (jqxhrError)->
      model.set
        loading_substructure_highlight: false
        download_highlighted_error: true
        reference_smiles_error: true
        reference_smiles_error_jqxhr: jqxhrError
      model.trigger glados.Events.Compound.STRUCTURE_HIGHLIGHT_ERROR
    return promise

  #---------------------------------------------------------------------------------------------------------------------
  # 3D SDF
  #---------------------------------------------------------------------------------------------------------------------

  download2DSDF: ()->
    @set('sdf2DError', false, {silent: true})
    promiseFunc = (resolve, reject)->
      if @get('sdf2DData')?
        resolve(@get('sdf2DData'))
      else
        ajax_deferred = $.get(Compound.SDF_2D_URL + @get('molecule_chembl_id') + '.sdf')
        compoundModel = @
        ajax_deferred.done (ajaxData)->
          compoundModel.set('sdf2DData', ajaxData)
          resolve(ajaxData)
        ajax_deferred.fail (error)->
          compoundModel.set('sdf2DError', true)
          reject(error)
    return new Promise(promiseFunc.bind(@))

  download3DSDF: (endpointIndex)->
    @set('sdf3DError', false, {silent: true})
    data3DCacheName = 'sdf3DData_'+endpointIndex
    promiseFunc = (resolve, reject)->
      if not @get('sdf2DData')?
        error = 'Error, There is no 2D data for the compound '+@get('molecule_chembl_id')+'!'
        compoundModel.set('sdf3DError', true)
        console.error error
        reject(error)
      else if @get(data3DCacheName)?
        resolve(data3DCacheName)
      else
        ajax_deferred = $.post(Compound.SDF_3D_ENDPOINTS[endpointIndex], @get('sdf2DData'))
        compoundModel = @
        ajax_deferred.done (ajaxData)->
          compoundModel.set(data3DCacheName, ajaxData)
          resolve(ajaxData)
        ajax_deferred.fail (error)->
          compoundModel.set('sdf3DError', true)
          reject()
    return new Promise(promiseFunc.bind(@))

  download3DXYZ: (endpointIndex)->
    @set('xyz3DError', false, {silent: true})
    dataVarName = 'sdf3DDataXYZ_'+endpointIndex
    data3DSDFVarName = 'sdf3DData_'+endpointIndex
    promiseFunc = (resolve, reject)->
      if not @get('current3DData')?
        error = 'Error, There is no 3D data for the compound '+@get('molecule_chembl_id')+'!'
        compoundModel.set('xyz3DError', true)
        console.error error
        reject(error)
      else if @get(dataVarName)?
        resolve(dataVarName)
      else
        formData = new FormData()
        formData.append('file', new Blob([@get(data3DSDFVarName)], {type: 'chemical/x-mdl-molfile'}), 'aligned.mol')
        formData.set('computeCoords', 0)

        ajax_deferred = $.post
          url: Compound.SDF_3D_2_XYZ
          data: formData
          enctype: 'multipart/form-data'
          processData: false
          contentType: false
          cache: false
        compoundModel = @
        ajax_deferred.done (ajaxData)->
          compoundModel.set(dataVarName, ajaxData)
          resolve(ajaxData)
        ajax_deferred.fail (error)->
          compoundModel.set('xyz3DError', true)
          reject()
    return new Promise(promiseFunc.bind(@))


  calculate3DSDFAndXYZ: (endpointIndex)->
    @set
      cur3DEndpointIndex: endpointIndex
      current3DData: null
      current3DXYZData: null
    @trigger 'change:current3DData'
    @trigger 'change:current3DXYZData'
    dataVarName = 'sdf3DData_'+endpointIndex
    dataXYZVarName = 'sdf3DDataXYZ_'+endpointIndex

    after3DDownload = ()->
      @set('current3DData', @get(dataVarName))
      afterXYZDownload = ()->
        @set('current3DXYZData', @get(dataXYZVarName))
      @download3DXYZ(endpointIndex).then afterXYZDownload.bind(@)
    after3DDownload = after3DDownload.bind(@)

    download3DPromise = @download3DSDF.bind(@, endpointIndex)
    @download2DSDF().then ()->
      download3DPromise().then(after3DDownload)

#-----------------------------------------------------------------------------------------------------------------------
# 3D SDF Constants
#-----------------------------------------------------------------------------------------------------------------------

Compound.SDF_2D_ALIGN_URL = glados.Settings.BEAKER_BASE_URL + 'align'
Compound.SDF_2D_HIGHLIGHT_URL = glados.Settings.BEAKER_BASE_URL + 'highlightCtabFragmentSvg'
Compound.SDF_2D_URL = glados.Settings.WS_BASE_URL + 'molecule/'
Compound.SDF_3D_2_XYZ = glados.Settings.BEAKER_BASE_URL + 'ctab2xyz'
Compound.SMILES_2_SIMILARITY_MAP_URL = glados.Settings.BEAKER_BASE_URL + 'smiles2SimilarityMap'
Compound.SDF_3D_ENDPOINTS = [
  {
    label: 'UFF'
    url: glados.Settings.BEAKER_BASE_URL+ 'ctab23D'
  },
  {
    label: 'MMFF'
    url: glados.Settings.BEAKER_BASE_URL+ 'MMFFctab23D'
  },
  {
    label: 'ETKDG'
    url: glados.Settings.BEAKER_BASE_URL+ 'ETKDGctab23D'
  },
  {
    label: 'KDG'
    url: glados.Settings.BEAKER_BASE_URL+ 'KDGctab23D'
  }
]

# Constant definition for ReportCardEntity model functionalities
_.extend(Compound, glados.models.base.ReportCardEntity)
Compound.color = 'cyan'
Compound.reportCardPath = 'compound_report_card/'

Compound.getSDFURL = (chemblId) -> glados.Settings.WS_BASE_URL + 'molecule/' + chemblId + '.sdf'

Compound.INDEX_NAME = 'chembl_molecule'
Compound.COLUMNS = {
  CHEMBL_ID: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_chembl_id'
    link_base: 'report_card_url'
    image_base_url: 'image_url'
  SYNONYMS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_synonyms'
    parse_function: (values) -> _.uniq(v.molecule_synonym for v in values).join(', ')
  PREF_NAME: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'pref_name'
  MOLECULE_TYPE: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_type'
  MAX_PHASE: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'max_phase'
  DOSED_INGREDIENT: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: 'Dosed Ingredient'
    comparator: 'dosed_ingredient'
  SIMILARITY: {
      'name_to_show': 'Similarity'
      'comparator': 'similarity'
      'sort_disabled': false
      'is_sorting': 0
      'sort_class': 'fa-sort'
      'custom_field_template': '<b>{{val}}</b>'
    }
  SIMILARITY_ELASTIC: {
      'name_to_show': 'Similarity'
      'comparator': '_score'
      'sort_disabled': false
      'is_sorting': 0
      'sort_class': 'fa-sort'
      is_elastic_score: true
    }
  STRUCTURE_TYPE: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'structure_type'
  INORGANIC_FLAG: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'inorganic_flag'
  FULL_MWT: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.full_mwt'
  FULL_MWT_CARD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: 'MWt'
    comparator: 'molecule_properties.full_mwt'
  ALOGP: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.alogp'
  HBA: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.hba'
  HBD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.hbd'
  HEAVY_ATOMS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.heavy_atoms'
  PSA: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.psa'
  RO5: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.num_ro5_violations'
  RO5_CARD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: '#RO5'
    comparator: 'molecule_properties.num_ro5_violations'
  ROTATABLE_BONDS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.rtb'
  ROTATABLE_BONDS_CARD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: '#RTB'
    comparator: 'molecule_properties.rtb'
  RULE_OF_THREE_PASS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.ro3_pass'
  RULE_OF_THREE_PASS_CARD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: 'Passes Rule of Three'
    comparator: 'molecule_properties.ro3_pass'
  QED_WEIGHTED: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.qed_weighted'
  APKA: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.acd_most_apka'
  BPKA: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.acd_most_bpka'
  ACD_LOGP: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.acd_logp'
  ACD_LOGD: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.acd_logd'
  AROMATIC_RINGS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.aromatic_rings'
  HEAVY_ATOMS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.heavy_atoms'
  HBA_LIPINSKI: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.hba_lipinski'
  HBD_LIPINSKI: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.hbd_lipinski'
  RO5_LIPINSKI: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.num_lipinski_ro5_violations'
  MWT_MONOISOTOPIC: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.mw_monoisotopic'
  MOLECULAR_SPECIES: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.molecular_species'
  FULL_MOLFORMULA: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: 'molecule_properties.full_molformula'
  NUM_TARGETS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: '_metadata.related_targets.count'
    format_as_number: true
    link_base: 'targets_url'
    secondary_link: true
    on_click: CompoundReportCardApp.initMiniHistogramFromFunctionLink
    function_parameters: ['molecule_chembl_id']
    function_constant_parameters: ['targets']
    function_key: 'targets'
    function_link: true
    execute_on_render: true
    format_class: 'number-cell-center'
  NUM_TARGETS_BY_CLASS: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    name_to_show: 'Targets (by Class)'
    comparator: '_metadata.related_targets.count'
    format_as_number: true
    link_base: 'targets_url'
    secondary_link: true
    on_click: CompoundReportCardApp.initMiniHistogramFromFunctionLink
    function_parameters: ['molecule_chembl_id']
    function_constant_parameters: ['targets_by_class']
    function_key: 'compound_targets_by_class'
    function_link: true
    execute_on_render: true
    format_class: 'number-cell-center'
  BIOACTIVITIES_NUMBER: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: '_metadata.activity_count'
    link_base: 'activities_url'
    on_click: CompoundReportCardApp.initMiniHistogramFromFunctionLink
    function_parameters: ['molecule_chembl_id']
    function_constant_parameters: ['activities']
    # to help bind the link to the function, it could be necessary to always use the key of the columns descriptions
    # or probably not, depending on how this evolves
    function_key: 'bioactivities'
    function_link: true
    execute_on_render: true
    format_class: 'number-cell-center'
    secondary_link: true
  COMPOUND_SOURCES_LIST: glados.models.paginatedCollections.ColumnsFactory.generateColumn Compound.INDEX_NAME,
    comparator: '_metadata.compound_records'
    name_to_show: 'Compound Sources'
    parse_function: (values) -> (v.src_description for v in values)
}

Compound.ID_COLUMN = Compound.COLUMNS.CHEMBL_ID

Compound.COLUMNS_SETTINGS = {
  ALL_COLUMNS: (->
    colsList = []
    for key, value of Compound.COLUMNS
      colsList.push value
    return colsList
  )()
  RESULTS_LIST_TABLE: [
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.PREF_NAME
    Compound.COLUMNS.SYNONYMS,
    Compound.COLUMNS.MOLECULE_TYPE,
    Compound.COLUMNS.MAX_PHASE,
    Compound.COLUMNS.FULL_MWT,
    Compound.COLUMNS.NUM_TARGETS,
    Compound.COLUMNS.BIOACTIVITIES_NUMBER,
    Compound.COLUMNS.ALOGP,
    Compound.COLUMNS.PSA,
    Compound.COLUMNS.HBA,
    Compound.COLUMNS.HBD,
    Compound.COLUMNS.RO5,
    Compound.COLUMNS.ROTATABLE_BONDS,
    Compound.COLUMNS.RULE_OF_THREE_PASS,
    Compound.COLUMNS.QED_WEIGHTED
  ]
  RESULTS_LIST_REPORT_CARD:[
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.PREF_NAME
  ]
  RESULTS_LIST_REPORT_CARD_LONG:[
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.PREF_NAME,
    Compound.COLUMNS.MOLECULE_TYPE
    Compound.COLUMNS.MAX_PHASE,
    Compound.COLUMNS.FULL_MWT,
    Compound.COLUMNS.ALOGP,
    Compound.COLUMNS.NUM_TARGETS,
    Compound.COLUMNS.BIOACTIVITIES_NUMBER
  ]
  MINI_REPORT_CARD:[
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.PREF_NAME,
    Compound.COLUMNS.SYNONYMS,
    Compound.COLUMNS.MAX_PHASE,
    Compound.COLUMNS.FULL_MWT,
    Compound.COLUMNS.ALOGP,
    Compound.COLUMNS.PSA,
    Compound.COLUMNS.HBA,
    Compound.COLUMNS.HBD,
    Compound.COLUMNS.RO5,
    Compound.COLUMNS.NUM_TARGETS,
    Compound.COLUMNS.BIOACTIVITIES_NUMBER
  ]
  RESULTS_LIST_REPORT_CARD_ADDITIONAL:[
    Compound.COLUMNS.APKA,
    Compound.COLUMNS.BPKA,
    Compound.COLUMNS.ACD_LOGP,
    Compound.COLUMNS.ACD_LOGD,
    Compound.COLUMNS.AROMATIC_RINGS,
    Compound.COLUMNS.STRUCTURE_TYPE,
    Compound.COLUMNS.INORGANIC_FLAG,
    Compound.COLUMNS.HEAVY_ATOMS,
    Compound.COLUMNS.HBA_LIPINSKI,
    Compound.COLUMNS.HBD_LIPINSKI,
    Compound.COLUMNS.RO5_LIPINSKI,
    Compound.COLUMNS.MWT_MONOISOTOPIC,
    Compound.COLUMNS.MOLECULAR_SPECIES,
    Compound.COLUMNS.FULL_MOLFORMULA,
#    Compound.COLUMNS.NUM_TARGETS_BY_CLASS
  ]
  RESULTS_LIST_SIMILARITY:[
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.SIMILARITY,
    Compound.COLUMNS.MOLECULE_TYPE,
    Compound.COLUMNS.PREF_NAME,
  ]
  RESULTS_LIST_REPORT_CARD_CAROUSEL: [
    Compound.COLUMNS.CHEMBL_ID,
  ]
  TEST: [
    Compound.COLUMNS.CHEMBL_ID,
    Compound.COLUMNS.PREF_NAME
    Compound.COLUMNS.MAX_PHASE,
  ]
  COMPOUND_SOURCES_SECTION: [
    Compound.COLUMNS.COMPOUND_SOURCES_LIST
  ]
}

Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS = _.union(Compound.COLUMNS_SETTINGS.RESULTS_LIST_TABLE,
  Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL)

Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS_SIMILARITY = _.union(
  Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS,
  [Compound.COLUMNS.SIMILARITY_ELASTIC])

Compound.MINI_REPORT_CARD =
  LOADING_TEMPLATE: 'Handlebars-Common-MiniRepCardPreloader'
  TEMPLATE: 'Handlebars-Common-MiniReportCard'
  COLUMNS: Compound.COLUMNS_SETTINGS.MINI_REPORT_CARD

Compound.getCompoundsListURL = (filter) ->

  if filter
    return glados.Settings.GLADOS_BASE_PATH_REL + 'compounds/filter/' + encodeURIComponent(filter)
  else
    return glados.Settings.GLADOS_BASE_PATH_REL + 'compounds'