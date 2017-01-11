describe "Paginated Collection", ->


  describe "A 3 elements collection", ->

    appDrugCCList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewApprovedDrugsClinicalCandidatesList()

    dataSmall = [{"action_type":"INHIBITOR","binding_site_comment":"Binding site 23S and 16S RNA (interface)","direct_interaction":true,"disease_efficacy":true,"mec_id":2069,"mechanism_comment":null,"mechanism_of_action":"70S ribosome inhibitor","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200526","record_id":1343516,"selectivity_comment":null,"site_id":2623,"target_chembl_id":"CHEMBL2363965","max_phase":4,"pref_name":"VIOMYCIN SULFATE"},{"action_type":"INHIBITOR","binding_site_comment":"Binding site 23S and 16S RNA (interface)","direct_interaction":true,"disease_efficacy":true,"mec_id":2070,"mechanism_comment":null,"mechanism_of_action":"70S ribosome inhibitor","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL2218913","record_id":1344356,"selectivity_comment":null,"site_id":2623,"target_chembl_id":"CHEMBL2363965","max_phase":4,"pref_name":"CAPREOMYCIN SULFATE"},{"action_type":"INHIBITOR","binding_site_comment":"30S ribosomal protein S1","direct_interaction":true,"disease_efficacy":true,"mec_id":2071,"mechanism_comment":null,"mechanism_of_action":"70S ribosome inhibitor","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL614","record_id":1344577,"selectivity_comment":null,"site_id":2659,"target_chembl_id":"CHEMBL2363965","max_phase":4,"pref_name":"PYRAZINAMIDE"}]

    beforeAll ->
      appDrugCCList.reset(dataSmall)

    afterAll: ->
      appDrugCCList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewApprovedDrugsClinicalCandidatesList()
      appDrugCCList.reset(dataSmall)

    it "initialises correctly", ->

      page_size = appDrugCCList.getMeta('page_size')
      current_page = appDrugCCList.getMeta('current_page')
      total_pages = appDrugCCList.getMeta('total_pages')
      total_records = appDrugCCList.getMeta('total_records')
      records_in_page = appDrugCCList.getMeta('records_in_page')

      expect(page_size).toBe(10)
      expect(current_page).toBe(1)
      expect(total_pages).toBe(1)
      expect(total_records).toBe(3)
      expect(records_in_page).toBe(3)

    it "gives the first page correctly", ->

      assert_chembl_ids(appDrugCCList, ["CHEMBL1200526", "CHEMBL2218913", "CHEMBL614"])

    it "sorts the collection by name (ascending)", ->

      appDrugCCList.sortCollection('pref_name')
      assert_chembl_ids(appDrugCCList, ["CHEMBL2218913", "CHEMBL614", "CHEMBL1200526"])

    it "sorts the collection by name (descending)", ->

      appDrugCCList.reset(dataSmall)
      appDrugCCList.resetMeta()

      appDrugCCList.sortCollection('pref_name')
      appDrugCCList.sortCollection('pref_name')

      assert_chembl_ids(appDrugCCList, ["CHEMBL1200526", "CHEMBL614", "CHEMBL2218913"])

    it "searches for a CHEMBL1200526", ->

      appDrugCCList.setSearch('CHEMBL1200526')
      assert_chembl_ids(appDrugCCList, ["CHEMBL1200526"])


  describe "A 5 elements collection, having 5 elements per page", ->

    drugList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewDrugList()
    drugList.setMeta('page_size', 5)
    drugList.setMeta('server_side', true)

    data5 = [ { atc_classifications: [ ], availability_type: "-1", biotherapeutic: null, black_box_warning: "0", chebi_par_id: null, chirality: "-1", dosed_ingredient: false, first_approval: null, first_in_class: "-1", helm_notation: null, indication_class: null, inorganic_flag: "-1", max_phase: 0, molecule_chembl_id: "CHEMBL6939", molecule_hierarchy: { molecule_chembl_id: "CHEMBL6939", parent_chembl_id: "CHEMBL6939" }, molecule_properties: { acd_logd: "0.16", acd_logp: "2.25", acd_most_apka: "13.86", acd_most_bpka: "9.42", alogp: "2.26", aromatic_rings: 1, full_molformula: "C17H27NO3", full_mwt: "293.40", hba: 4, hbd: 2, heavy_atoms: 21, molecular_species: "BASE", mw_freebase: "293.40", mw_monoisotopic: "293.1991", num_alerts: 0, num_ro5_violations: 0, psa: "50.72", qed_weighted: "0.70", ro3_pass: "N", rtb: 10 }, molecule_structures: { canonical_smiles: "CC(C)NCC(O)COc1ccc(COCC2CC2)cc1", standard_inchi: "InChI=1S/C17H27NO3/c1-13(2)18-9-16(19)12-21-17-7-5-15(6-8-17)11-20-10-14-3-4-14/h5-8,13-14,16,18-19H,3-4,9-12H2,1-2H3", standard_inchi_key: "UOKWVICUCYNXFO-UHFFFAOYSA-N" }, molecule_synonyms: [ ], molecule_type: "Small molecule", natural_product: "-1", oral: false, parenteral: false, polymer_flag: false, pref_name: null, prodrug: "-1", structure_type: "MOL", therapeutic_flag: false, topical: false, usan_stem: null, usan_stem_definition: null, usan_substem: null, usan_year: null }, { atc_classifications: [ "J01EA01" ], availability_type: "1", biotherapeutic: null, black_box_warning: "0", chebi_par_id: 45924, chirality: "2", dosed_ingredient: true, first_approval: 1973, first_in_class: "0", helm_notation: null, indication_class: "Antibacterial", inorganic_flag: "0", max_phase: 4, molecule_chembl_id: "CHEMBL22", molecule_hierarchy: { molecule_chembl_id: "CHEMBL22", parent_chembl_id: "CHEMBL22" }, molecule_properties: { acd_logd: "0.47", acd_logp: "0.59", acd_most_apka: null, acd_most_bpka: "6.90", alogp: "1.54", aromatic_rings: 2, full_molformula: "C14H18N4O3", full_mwt: "290.32", hba: 7, hbd: 2, heavy_atoms: 21, molecular_species: "NEUTRAL", mw_freebase: "290.32", mw_monoisotopic: "290.1379", num_alerts: 0, num_ro5_violations: 0, psa: "105.51", qed_weighted: "0.86", ro3_pass: "N", rtb: 5 }, molecule_structures: { canonical_smiles: "COc1cc(Cc2cnc(N)nc2N)cc(OC)c1OC", standard_inchi: "InChI=1S/C14H18N4O3/c1-19-10-5-8(6-11(20-2)12(10)21-3)4-9-7-17-14(16)18-13(9)15/h5-7H,4H2,1-3H3,(H4,15,16,17,18)", standard_inchi_key: "IEDVJHCEMCRBQM-UHFFFAOYSA-N" }, molecule_synonyms: [ { syn_type: "RESEARCH_CODE", synonyms: "BW-56-72" }, { syn_type: "OTHER", synonyms: "Polytrim" }, { syn_type: "OTHER", synonyms: "Primsol" }, { syn_type: "TRADE_NAME", synonyms: "Proloprim" }, { syn_type: "TRADE_NAME", synonyms: "Trimethoprim" }, { syn_type: "TRADE_NAME", synonyms: "Trimpex" }, { syn_type: "TRADE_NAME", synonyms: "Trimpex 200" }, { syn_type: "RESEARCH_CODE", synonyms: "BW-5672" }, { syn_type: "BAN", synonyms: "Trimethoprim" }, { syn_type: "FDA", synonyms: "Trimethoprim" }, { syn_type: "INN", synonyms: "Trimethoprim" }, { syn_type: "JAN", synonyms: "Trimethoprim" }, { syn_type: "USP", synonyms: "Trimethoprim" }, { syn_type: "USAN", synonyms: "Trimethoprim" }, { syn_type: "TRADE_NAME", synonyms: "Monotrim" }, { syn_type: "TRADE_NAME", synonyms: "Proloprin" }, { syn_type: "RESEARCH_CODE", synonyms: "TCMDC-125538" }, { syn_type: "OTHER", synonyms: "TCMDC-125538" } ], molecule_type: "Small molecule", natural_product: "0", oral: true, parenteral: true, polymer_flag: false, pref_name: "TRIMETHOPRIM", prodrug: "0", structure_type: "MOL", therapeutic_flag: true, topical: true, usan_stem: "-prim", usan_stem_definition: "antibacterials (trimethoprim type)", usan_substem: null, usan_year: 1964 }, { atc_classifications: [ ], availability_type: "-1", biotherapeutic: null, black_box_warning: "0", chebi_par_id: null, chirality: "-1", dosed_ingredient: false, first_approval: null, first_in_class: "-1", helm_notation: null, indication_class: null, inorganic_flag: "-1", max_phase: 0, molecule_chembl_id: "CHEMBL6941", molecule_hierarchy: { molecule_chembl_id: "CHEMBL6941", parent_chembl_id: "CHEMBL6941" }, molecule_properties: { acd_logd: "-0.83", acd_logp: "1.67", acd_most_apka: "-0.29", acd_most_bpka: "10.50", alogp: "2.06", aromatic_rings: 2, full_molformula: "C8H7N3S", full_mwt: "177.23", hba: 4, hbd: 2, heavy_atoms: 12, molecular_species: "ZWITTERION", mw_freebase: "177.23", mw_monoisotopic: "177.0361", num_alerts: 2, num_ro5_violations: 0, psa: "90.60", qed_weighted: "0.48", ro3_pass: "N", rtb: 0 }, molecule_structures: { canonical_smiles: "Nc1nc(S)c2ccccc2n1", standard_inchi: "InChI=1S/C8H7N3S/c9-8-10-6-4-2-1-3-5(6)7(12)11-8/h1-4H,(H3,9,10,11,12)", standard_inchi_key: "ZJAKAAVAZAYRLO-UHFFFAOYSA-N" }, molecule_synonyms: [ ], molecule_type: "Small molecule", natural_product: "-1", oral: false, parenteral: false, polymer_flag: false, pref_name: null, prodrug: "-1", structure_type: "MOL", therapeutic_flag: false, topical: false, usan_stem: null, usan_stem_definition: null, usan_substem: null, usan_year: null }, { atc_classifications: [ ], availability_type: "-1", biotherapeutic: null, black_box_warning: "0", chebi_par_id: null, chirality: "-1", dosed_ingredient: false, first_approval: null, first_in_class: "-1", helm_notation: null, indication_class: null, inorganic_flag: "-1", max_phase: 0, molecule_chembl_id: "CHEMBL6942", molecule_hierarchy: { molecule_chembl_id: "CHEMBL6942", parent_chembl_id: "CHEMBL6942" }, molecule_properties: { acd_logd: "3.80", acd_logp: "4.36", acd_most_apka: "13.50", acd_most_bpka: "7.88", alogp: "4.86", aromatic_rings: 4, full_molformula: "C24H25N5OS", full_mwt: "431.55", hba: 6, hbd: 3, heavy_atoms: 31, molecular_species: "NEUTRAL", mw_freebase: "431.55", mw_monoisotopic: "431.1780", num_alerts: 1, num_ro5_violations: 0, psa: "132.22", qed_weighted: "0.39", ro3_pass: "N", rtb: 5 }, molecule_structures: { canonical_smiles: "CC(C)C(Sc1ccc2ccccc2c1)C(=O)Nc3ccc4nc(N)nc(N)c4c3C", standard_inchi: "InChI=1S/C24H25N5OS/c1-13(2)21(31-17-9-8-15-6-4-5-7-16(15)12-17)23(30)27-18-10-11-19-20(14(18)3)22(25)29-24(26)28-19/h4-13,21H,1-3H3,(H,27,30)(H4,25,26,28,29)", standard_inchi_key: "PWTQBCOCKQEHQK-UHFFFAOYSA-N" }, molecule_synonyms: [ ], molecule_type: "Small molecule", natural_product: "-1", oral: false, parenteral: false, polymer_flag: false, pref_name: null, prodrug: "-1", structure_type: "MOL", therapeutic_flag: false, topical: false, usan_stem: null, usan_stem_definition: null, usan_substem: null, usan_year: null }, { atc_classifications: [ ], availability_type: "-1", biotherapeutic: null, black_box_warning: "0", chebi_par_id: null, chirality: "-1", dosed_ingredient: false, first_approval: null, first_in_class: "-1", helm_notation: null, indication_class: null, inorganic_flag: "-1", max_phase: 0, molecule_chembl_id: "CHEMBL6944", molecule_hierarchy: { molecule_chembl_id: "CHEMBL6944", parent_chembl_id: "CHEMBL6944" }, molecule_properties: { acd_logd: "-0.03", acd_logp: "2.77", acd_most_apka: "4.50", acd_most_bpka: null, alogp: "0.90", aromatic_rings: 1, full_molformula: "C12H13NO4S", full_mwt: "267.30", hba: 4, hbd: 1, heavy_atoms: 18, molecular_species: "ACID", mw_freebase: "267.30", mw_monoisotopic: "267.0565", num_alerts: 1, num_ro5_violations: 0, psa: "95.08", qed_weighted: "0.80", ro3_pass: "N", rtb: 5 }, molecule_structures: { canonical_smiles: "CCOC(=O)C1=C(O)C(=O)N(Cc2cccs2)C1", standard_inchi: "InChI=1S/C12H13NO4S/c1-2-17-12(16)9-7-13(11(15)10(9)14)6-8-4-3-5-18-8/h3-5,14H,2,6-7H2,1H3", standard_inchi_key: "LCDLJTYTVMVKMU-UHFFFAOYSA-N" }, molecule_synonyms: [ ], molecule_type: "Small molecule", natural_product: "-1", oral: false, parenteral: false, polymer_flag: false, pref_name: null, prodrug: "-1", structure_type: "MOL", therapeutic_flag: false, topical: false, usan_stem: null, usan_stem_definition: null, usan_substem: null, usan_year: null } ]

    beforeAll ->
      drugList.reset(data5)

    it "gives the first page correctly", ->

      assert_chembl_ids(drugList, ["CHEMBL6939", "CHEMBL22", "CHEMBL6941", "CHEMBL6942", "CHEMBL6944"])


  describe "A 68 elements collection", ->

    dataBig = [{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":801,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1091","record_id":1343865,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"HYDROCORTISONE ACETATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":811,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1152","record_id":1343831,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"PREDNISOLONE ACETATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":768,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1159650","record_id":1344368,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"CLOBETASOL PROPIONATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":802,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1161","record_id":1344391,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"MOMETASONE FUROATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":777,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200342","record_id":1343447,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"PARAMETHASONE ACETATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":795,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200376","record_id":1344911,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"BETAMETHASONE BENZOATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":778,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200384","record_id":1343300,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"BETAMETHASONE DIPROPIONATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":783,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200386","record_id":1344502,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"PREDNICARBATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":796,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200449","record_id":1344251,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"TRIAMCINOLONE DIACETATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":769,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200495","record_id":1344612,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"HYDROCORTISONE SODIUM SUCCINATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":784,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200500","record_id":1343414,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"BECLOMETHASONE DIPROPIONATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":779,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200538","record_id":1344293,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"BETAMETHASONE ACETATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":785,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200545","record_id":1343517,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"DIFLORASONE DIACETATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":797,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200562","record_id":1344677,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"HYDROCORTISONE VALERATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":770,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200600","record_id":1343503,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"FLUOROMETHOLONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":816,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200617","record_id":1344010,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"RIMEXOLONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":771,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200635","record_id":1344481,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"HYDROCORTAMATE HYDROCHLORIDE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":780,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200637","record_id":1344178,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"DEXAMETHASONE SODIUM PHOSPHATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":798,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200732","record_id":1343325,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"AMCINONIDE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":772,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200762","record_id":1344294,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"BETAMETHASONE SODIUM PHOSPHATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":805,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200774","record_id":1343056,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"FLUPREDNISOLONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":817,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200844","record_id":1344438,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"METHYLPREDNISOLONE ACETATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":761,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200845","record_id":1344066,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"HALCINONIDE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":773,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200865","record_id":1343629,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"LOTEPREDNOL ETABONATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":786,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200877","record_id":1344383,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"FLUMETHASONE PIVALATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":806,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200878","record_id":1343507,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"TRIAMCINOLONE HEXACETONIDE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":787,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200908","record_id":1343706,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"HALOBETASOL PROPIONATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":774,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200909","record_id":1343996,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"PREDNISOLONE TEBUTATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":818,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200953","record_id":1343676,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"HYDROCORTISONE PROBUTATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":788,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200968","record_id":1343405,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"HYDROCORTISONE SODIUM PHOSPHATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":807,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200975","record_id":1343980,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"CLOCORTOLONE PIVALATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":799,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1200989","record_id":1343698,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"ALCLOMETASONE DIPROPIONATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":819,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1201012","record_id":1343439,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"FLURANDRENOLIDE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":800,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1201014","record_id":1343304,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"PREDNISOLONE SODIUM PHOSPHATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":789,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1201064","record_id":1343771,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"FLUOROMETHOLONE ACETATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":781,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1201081","record_id":1343289,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"METHYLPREDNISOLONE SODIUM SUCCINATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":782,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1201109","record_id":1344145,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"DESONIDE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":808,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1201148","record_id":1343631,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"MEPREDNISONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":762,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1201173","record_id":1344648,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"MEDRYSONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":763,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1201749","record_id":1344517,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"DIFLUPREDNATE"},{"action_type":"ANTAGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":821,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor antagonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1276308","record_id":1344451,"selectivity_comment":"Selective","site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"MIFEPRISTONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":775,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL131","record_id":1344057,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"PREDNISOLONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":812,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1370","record_id":1343876,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"BUDESONIDE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":791,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1451","record_id":1344367,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"TRIAMCINOLONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":820,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1473","record_id":1344541,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"FLUTICASONE PROPIONATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":814,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1497","record_id":1344538,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"BETAMETHASONE VALERATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":792,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1501","record_id":1344076,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"FLUOCINONIDE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":766,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1504","record_id":1343594,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"TRIAMCINOLONE ACETONIDE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":776,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1512","record_id":1343379,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"FLUNISOLIDE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":767,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1549","record_id":1344409,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"HYDROCORTISONE CYPIONATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":815,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1650","record_id":1344638,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"CORTISONE ACETATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":803,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1651","record_id":1344659,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"DEXAMETHASONE ACETATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":793,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1676","record_id":1344879,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"FLUTICASONE FUROATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":804,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1683","record_id":1343159,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"HYDROCORTISONE BUTYRATE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":794,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL1766","record_id":1344891,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"DESOXIMETASONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":809,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL2040682","record_id":1344946,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"CICLESONIDE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":3642,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL2103876","record_id":2473502,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":3,"pref_name":"MAPRACORAT"},{"action_type":"ANTAGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":2457,"mechanism_comment":"Company reports initiation of No Ph1 trial in 2010 but no ID found and no further trials planned. Discontinuedcompound?","mechanism_of_action":"Glucocorticoid receptor antagonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL271220","record_id":2473754,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":1,"pref_name":"CORT 108297"},{"action_type":"MODULATOR","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":2968,"mechanism_comment":"Active metbolite of PF-04171327","mechanism_of_action":"Glucocorticoid receptor modulator","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL3137304","record_id":2472971,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":2,"pref_name":"DAGROCORAT"},{"action_type":"MODULATOR","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":3630,"mechanism_comment":"pro-drug of PF-00251802. Indication: Rheumatoid Arthritis","mechanism_of_action":"Glucocorticoid receptor modulator","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL3137316","record_id":2473415,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":2,"pref_name":"FOSDAGROCORAT"},{"action_type":"ANTAGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":2458,"mechanism_comment":"Ph1 trial initiated in Septemebr 2014, no trial ID found.","mechanism_of_action":"Glucocorticoid receptor antagonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL3544957","record_id":2472766,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":1,"pref_name":"CORT 125134"},{"action_type":"ANTAGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":2969,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor antagonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL3545391","record_id":2473704,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":2,"pref_name":"ORG-34517"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":813,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL384467","record_id":1344337,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"DEXAMETHASONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":765,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL389621","record_id":1343850,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"HYDROCORTISONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":764,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL632","record_id":1343565,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"BETAMETHASONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":760,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL635","record_id":1344798,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"PREDNISONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":790,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL650","record_id":1344148,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"METHYLPREDNISOLONE"},{"action_type":"AGONIST","binding_site_comment":null,"direct_interaction":true,"disease_efficacy":true,"mec_id":810,"mechanism_comment":null,"mechanism_of_action":"Glucocorticoid receptor agonist","molecular_mechanism":true,"molecule_chembl_id":"CHEMBL989","record_id":1343120,"selectivity_comment":null,"site_id":null,"target_chembl_id":"CHEMBL2034","max_phase":4,"pref_name":"FLUOCINOLONE ACETONIDE"}]

    appDrugCCList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewApprovedDrugsClinicalCandidatesList()

    beforeAll ->
      appDrugCCList.reset(dataBig)

    it "initialises correctly", ->

      page_size = appDrugCCList.getMeta('page_size')
      current_page = appDrugCCList.getMeta('current_page')
      total_pages = appDrugCCList.getMeta('total_pages')
      total_records = appDrugCCList.getMeta('total_records')
      records_in_page = appDrugCCList.getMeta('records_in_page')

      expect(page_size).toBe(10)
      expect(current_page).toBe(1)
      expect(total_pages).toBe(7)
      expect(total_records).toBe(68)
      expect(records_in_page).toBe(10)

    it "gives 5 records per page correctly", ->

      appDrugCCList.resetPageSize(5)

      to_show = appDrugCCList.getCurrentPage()
      chembl_ids = _.map(to_show, (o)-> o.get('molecule_chembl_id'))
      expected_chembl_ids = ["CHEMBL1091", "CHEMBL1152", "CHEMBL1159650", "CHEMBL1161", "CHEMBL1200342", "CHEMBL1200376"]

      comparator = _.zip(chembl_ids, expected_chembl_ids)
      for elem in comparator
        expect(elem[0]).toBe(elem[1])

      total_pages = appDrugCCList.getMeta('total_pages')
      expect(total_pages).toBe(14)

    it "gives page 7 correctly with 5 per page", ->

      appDrugCCList.resetPageSize(5)
      appDrugCCList.setPage(7)

      to_show = appDrugCCList.getCurrentPage()
      chembl_ids = _.map(to_show, (o)-> o.get('molecule_chembl_id'))
      expected_chembl_ids = ["CHEMBL1200975", "CHEMBL1200989", "CHEMBL1201012", "CHEMBL1201014", "CHEMBL1201064", "CHEMBL1201081"]

      comparator = _.zip(chembl_ids, expected_chembl_ids)
      for elem in comparator
        expect(elem[0]).toBe(elem[1])


    it "gives last page correctly", ->

      appDrugCCList.resetPageSize(5)
      appDrugCCList.setPage(14)

      to_show = appDrugCCList.getCurrentPage()
      chembl_ids = _.map(to_show, (o)-> o.get('molecule_chembl_id'))
      expected_chembl_ids = ["CHEMBL635", "CHEMBL650", "CHEMBL989"]

      comparator = _.zip(chembl_ids, expected_chembl_ids)
      for elem in comparator
        expect(elem[0]).toBe(elem[1])

  describe "A server side collection", ->

    drugList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewDrugList()

#    drugList = new DrugList
    drugList.setMeta('page_size', 20)

    beforeEach (done) ->

      drugList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewDrugList()
      drugList.fetch
        success: done

    it "(SERVER DEPENDENT) initialises correctly", (done) ->

      page_size = drugList.getMeta('page_size')
      current_page = drugList.getMeta('current_page')
      total_pages = drugList.getMeta('total_pages')
      total_records = drugList.getMeta('total_records')
      records_in_page = drugList.getMeta('records_in_page')

      expect(page_size).toBe(20)
      expect(current_page).toBe(1)
      expect(total_pages).toBe(84335)
      expect(total_records).toBe(1686695)
      expect(records_in_page).toBe(20)

      done()

    it "defines the initial url", ->

      expect(drugList.url).toBe('https://www.ebi.ac.uk/chembl/api/data/molecule.json?limit=20&offset=0')


    it "defines the url for the 5th page", ->

      drugList.setPage(5)
      expect(drugList.url).toBe('https://www.ebi.ac.uk/chembl/api/data/molecule.json?limit=20&offset=80')

    it "defines the url after switching to 5 items per page", ->

      drugList.resetPageSize(5)
      expect(drugList.url).toBe('https://www.ebi.ac.uk/chembl/api/data/molecule.json?limit=5&offset=0')

    it "generates a correct paginated url (sorting)", ->

      drugList.sortCollection('molecule_chembl_id')
      url = drugList.getPaginatedURL()

      expect(url).toContain('order_by=molecule_chembl_id')


    it "generates a correct paginated url (search)", ->

      drugList.setSearch('25', 'molecule_chembl_id', 'text')
      drugList.setSearch('ASP', 'pref_name', 'text')

      url = drugList.getPaginatedURL()

      expect(url).toContain('molecule_chembl_id__contains=25')
      expect(url).toContain('pref_name__contains=ASP')



  describe "An elasticsearch collection", ->

    esList = glados.models.paginatedCollections.PaginatedCollectionFactory.getAllESResultsListDict()[ \
      glados.models.paginatedCollections.Settings.ES_INDEXES.COMPOUND
    ]

    beforeEach (done) ->
      esList = glados.models.paginatedCollections.PaginatedCollectionFactory.getAllESResultsListDict()[ \
        glados.models.paginatedCollections.Settings.ES_INDEXES.COMPOUND
      ]
      done()

    it "Sets initial parameters", ->

      expect(esList.getMeta('current_page')).toBe(1)
      expect(esList.getMeta('index')).toBe('/chembl_molecule')
      expect(esList.getMeta('page_size')).toBe(6)

    it "Sets the request data to get the 5th page", ->

      esList.setPage(5)
      expect(esList.getURL()).toBe(glados.models.paginatedCollections.Settings.ES_BASE_URL+'/chembl_molecule/_search')

      requestData = esList.getRequestData()
      expect(requestData['from']).toBe(0)
      expect(requestData['size']).toBe(6)

    it "Sets the request data to switch to 10 items per page", ->

      esList.resetPageSize(10)
      expect(esList.getURL()).toBe(glados.models.paginatedCollections.Settings.ES_BASE_URL+'/chembl_molecule/_search')

      requestData = esList.getRequestData()
      expect(requestData['from']).toBe(0)
      expect(requestData['size']).toBe(10)

    #TODO: tests for sorting and filtering search



  # ------------------------------
  # Helpers
  # ------------------------------

  assert_chembl_ids = (collection, expected_chembl_ids) ->

    to_show = collection.getCurrentPage()
    chembl_ids = _.map(to_show, (o)-> o.get('molecule_chembl_id'))

    comparator = _.zip(chembl_ids, expected_chembl_ids)
    for elem in comparator
      expect(elem[0]).toBe(elem[1])







