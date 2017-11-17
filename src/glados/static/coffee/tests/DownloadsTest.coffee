describe "Downloads", ->

  data = {"molecule_chembl_id":"CHEMBL25","atc_classifications":["N02BA01","N02BA51","N02BA71","A01AD05","B01AC06"],"availability_type":"2","biotherapeutic":null,"black_box_warning":"0","chebi_par_id":15365,"chirality":"1","dosed_ingredient":true,"first_approval":1950,"first_in_class":"0","helm_notation":null,"indication_class":"Analgesic; Antirheumatic; Antipyretic","inorganic_flag":"0","max_phase":4,"molecule_hierarchy":{"molecule_chembl_id":"CHEMBL25","parent_chembl_id":"CHEMBL25"},"molecule_properties":{"acd_logd":"-1.68","acd_logp":"1.40","acd_most_apka":"3.48","acd_most_bpka":null,"alogp":"1.23","aromatic_rings":1,"full_molformula":"C9H8O4","full_mwt":"180.16","hba":4,"hbd":1,"heavy_atoms":13,"molecular_species":"ACID","mw_freebase":"180.16","mw_monoisotopic":"180.0423","num_alerts":2,"num_ro5_violations":0,"psa":"63.60","qed_weighted":"0.56","ro3_pass":"N","rtb":3},"molecule_structures":{"canonical_smiles":"CC(=O)Oc1ccccc1C(=O)O","standard_inchi":"InChI=1S/C9H8O4/c1-6(10)13-8-5-3-2-4-7(8)9(11)12/h2-5H,1H3,(H,11,12)","standard_inchi_key":"BSYNRYMUTXBXSQ-UHFFFAOYSA-N"},"molecule_synonyms":[{"syn_type":"TRADE_NAME","synonyms":"8-Hour Bayer"},{"syn_type":"TRADE_NAME","synonyms":"Acetosalic Acid"},{"syn_type":"INN","synonyms":"Acetylsalicylic Acid"},{"syn_type":"OTHER","synonyms":"Acetylsalicylic Acid"},{"syn_type":"TRADE_NAME","synonyms":"Acetylsalicylic Acid"},{"syn_type":"BAN","synonyms":"Aspirin"},{"syn_type":"FDA","synonyms":"Aspirin"},{"syn_type":"JAN","synonyms":"Aspirin"},{"syn_type":"TRADE_NAME","synonyms":"Aspirin"},{"syn_type":"USAN","synonyms":"Aspirin"},{"syn_type":"USP","synonyms":"Aspirin"},{"syn_type":"TRADE_NAME","synonyms":"Bayer Extra Strength"},{"syn_type":"TRADE_NAME","synonyms":"Ecotrin"},{"syn_type":"TRADE_NAME","synonyms":"Equi-Prin"},{"syn_type":"TRADE_NAME","synonyms":"Measurin"},{"syn_type":"TRADE_NAME","synonyms":"Salicylic Acid Acetate"}],"molecule_type":"Small molecule","natural_product":"0","oral":true,"parenteral":false,"polymer_flag":false,"pref_name":"ASPIRIN","prodrug":"0","structure_type":"MOL","therapeutic_flag":true,"topical":false,"usan_stem":null,"usan_stem_definition":null,"usan_substem":null,"usan_year":null,"ro5":true}
  aspirin = new Compound
  aspirin.set(data)

  describe "A simple object download", ->

    it 'A. generates a correct json file', (done) ->

      fileStrContent = aspirin.downloadJSON('DownloadTestA.json')
      testJSONFile(fileStrContent, glados.Settings.STATIC_URL+'testData/DownloadTestA.json', done)

    it 'B. generates a correct csv file', (done) ->

      expect(true).toBe(true) #TODO
      done()
#      fileStrContent = aspirin.downloadCSV('DownloadTestB.csv')
#      testTextFile(fileStrContent, glados.Settings.STATIC_URL+'testData/DownloadTestB.csv', done)

  describe "A model with custom download object", ->

    downloadParserFunction = (attributes) ->
      return [attributes.molecule_properties]

    it 'D. generates a correct json file', (done) ->

      fileStrContent = aspirin.downloadJSON('DownloadTestD.json', downloadParserFunction)
      testJSONFile(fileStrContent, glados.Settings.STATIC_URL+'testData/DownloadTestD.json', done)

    it 'E. generates a correct csv file', (done) ->

      expect(true).toBe(true) #TODO
      done()
#      fileStrContent = aspirin.downloadCSV('DownloadTestE.csv', downloadParserFunction)
#      testTextFile(fileStrContent, glados.Settings.STATIC_URL+'testData/DownloadTestE.csv', done)

  describe "A sdf download from a file list", ->

    DownloadModelOrCollectionExt.generateSDFFromChemblIDs ['CHEMBL59', 'CHEMBL251624', 'CHEMBL327561', 'CHEMBL465586' ]
    #TODO Finish this test! it neets to wait for the file to be built


  testTextFile = (currentContent, expectedFileUrl, done) ->
    $.get expectedFileUrl, (expectedFileContent) ->

      expect(currentContent).toBe(expectedFileContent)
      done()

  testJSONFile = (currentContent, expectedFileUrl, done) ->
    $.get expectedFileUrl, (expectedFileContent) ->

      expect(currentContent).toBe(JSON.stringify(expectedFileContent))
      done()

  # this is to make sure that we don't accidentally change the configurations
  describe "Download Columns Configuration", ->

    it 'Generates the configuration for Compounds', ->

      comparatorsMustBe = ["molecule_chembl_id","pref_name","molecule_synonyms","molecule_type","max_phase",
        "molecule_properties.full_mwt","_metadata.related_targets.count","_metadata.activity_count",
        "molecule_properties.alogp","molecule_properties.psa","molecule_properties.hba","molecule_properties.hbd",
        "molecule_properties.num_ro5_violations","molecule_properties.rtb","molecule_properties.ro3_pass",
        "molecule_properties.qed_weighted","molecule_properties.acd_most_apka","molecule_properties.acd_most_bpka",
        "molecule_properties.acd_logp","molecule_properties.acd_logd","molecule_properties.aromatic_rings",
        "structure_type","inorganic_flag","molecule_properties.heavy_atoms","molecule_properties.hba_lipinski",
        "molecule_properties.hbd_lipinski","molecule_properties.num_lipinski_ro5_violations",
        "molecule_properties.mw_monoisotopic","molecule_properties.molecular_species",
        "molecule_properties.full_molformula"]

      comparatorsGot = (col.comparator for col in Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS)
      expect(TestsUtils.listsAreEqual(comparatorsMustBe, comparatorsGot)).toBe(true)

    it 'Generates the configuration for Compounds (similarity Searches)', ->

      comparatorsMustBe = ["molecule_chembl_id","pref_name","molecule_synonyms","molecule_type","max_phase",
        "molecule_properties.full_mwt","_metadata.related_targets.count","_metadata.activity_count",
        "molecule_properties.alogp","molecule_properties.psa","molecule_properties.hba","molecule_properties.hbd",
        "molecule_properties.num_ro5_violations","molecule_properties.rtb","molecule_properties.ro3_pass",
        "molecule_properties.qed_weighted","molecule_properties.acd_most_apka","molecule_properties.acd_most_bpka",
        "molecule_properties.acd_logp","molecule_properties.acd_logd","molecule_properties.aromatic_rings",
        "structure_type","inorganic_flag","molecule_properties.heavy_atoms","molecule_properties.hba_lipinski",
        "molecule_properties.hbd_lipinski","molecule_properties.num_lipinski_ro5_violations",
        "molecule_properties.mw_monoisotopic","molecule_properties.molecular_species",
        "molecule_properties.full_molformula","_score"]

      comparatorsGot = (col.comparator for col in Compound.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS_SIMILARITY)
      expect(TestsUtils.listsAreEqual(comparatorsMustBe, comparatorsGot)).toBe(true)

    it 'Generates the configuration for Drugs', ->

      comparatorsMustBe = ["molecule_chembl_id","molecule_synonyms","molecule_synonyms","max_phase",
        "_metadata.drug.drug_data.applicants","usan_stem","usan_year","first_approval","atc_classifications",
        "--","usan_stem_definition","_metadata.drug.drug_data.usan_stem_substem","indication_class",
        "_metadata.drug.drug_data.sc_patent","withdrawn_year","withdrawn_reason","withdrawn_country"]

      comparatorsGot = (col.comparator for col in glados.models.Compound.Drug.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS)
      expect(TestsUtils.listsAreEqual(comparatorsMustBe, comparatorsGot)).toBe(true)

    it 'Generates the configuration for Targets', ->

      comparatorsMustBe = ["target_chembl_id","pref_name","target_components","target_type","organism",
       "_metadata.related_compounds.count","_metadata.activity_count","tax_id", "species_group_flag"]

      comparatorsGot = (col.comparator for col in Target.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS)
      expect(TestsUtils.listsAreEqual(comparatorsMustBe, comparatorsGot)).toBe(true)

    it 'Generates the configuration for Assays', ->

      comparatorsMustBe = ["assay_chembl_id", "description", "assay_organism", "document_chembl_id", "bao_label",
        "_metadata.source.src_description", "assay_tax_id", "assay_strain", "assay_type", "tissue_chembl_id",
        "assay_cell_type", "assay_subcellular_fraction"]

      comparatorsGot = (col.comparator for col in Assay.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS)
      console.log 'comparatorsGot: ', comparatorsGot
      expect(TestsUtils.listsAreEqual(comparatorsMustBe, comparatorsGot)).toBe(true)

    it 'Generates the configuration for Documents', ->

      comparatorsMustBe = ["document_chembl_id","journal","title","pubmed_id","doi","patent_id",
        "_metadata.source","authors","year","doc_type","abstract"]

      comparatorsGot = (col.comparator for col in Document.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS)
      console.log 'comparatorsGot: ', JSON.stringify(comparatorsGot)
      expect(TestsUtils.listsAreEqual(comparatorsMustBe, comparatorsGot)).toBe(true)

    it 'Generates the configuration for Cell Lines', ->

      comparatorsMustBe = ["cell_chembl_id","cell_name","cell_description","cell_source_organism",
        "cell_source_tissue","cell_source_tax_id", "clo_id","efo_id","cellosaurus_id","cl_lincs_id"]

      comparatorsGot = (col.comparator for col in CellLine.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS)
      expect(TestsUtils.listsAreEqual(comparatorsMustBe, comparatorsGot)).toBe(true)


    it 'Generates the configuration for Tissue', ->

      comparatorsMustBe = ["tissue_chembl_id","pref_name","uberon_id","efo_id","bto_id","caloha_id"]

      comparatorsGot = (col.comparator for col in glados.models.Tissue.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS)
      expect(TestsUtils.listsAreEqual(comparatorsMustBe, comparatorsGot)).toBe(true)

    it 'Generates the configuration for Activities', ->

      comparatorsMustBe = ["molecule_chembl_id","standard_type","standard_relation","standard_value",
        "standard_units","pchembl_value","activity_comment","assay_chembl_id","assay_description",
        "target_chembl_id","target_pref_name","target_organism", "document_chembl_id", "target_tax_id", "bao_format",
        "published_type","published_relation","published_value","published_units","canonical_smiles",
        "data_validity_comment","document_journal","document_year","src_id","uo_units","potential_duplicate",
        ]

      comparatorsGot = (col.comparator for col in Activity.COLUMNS_SETTINGS.DEFAULT_DOWNLOAD_COLUMNS)
      expect(TestsUtils.listsAreEqual(comparatorsMustBe, comparatorsGot)).toBe(true)