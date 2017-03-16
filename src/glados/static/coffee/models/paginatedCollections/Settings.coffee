glados.useNameSpace 'glados.models.paginatedCollections',
  # --------------------------------------------------------------------------------------------------------------------
  # Elastic Search specific configuration settings
  # --------------------------------------------------------------------------------------------------------------------
  Settings:
    ES_BASE_URL: 'https://wwwdev.ebi.ac.uk/chembl/glados-es'
    ES_INDEXES:
      COMPOUND:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESCompound'
        LABEL: 'Compounds'
        PATH: '/chembl_molecule'
        MODEL: Compound
        COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
        ID_COLUMN: Compound.ID_COLUMN
        COLUMNS_CARD: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        ADDITIONAL_COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_ADDITIONAL
        FACETS: glados.models.paginatedCollections.esSchema.CompoundSchema.FACETS
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV'], glados.Settings.DEFAULT_FILE_FORMAT_NAMES['SDF']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Matrix'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Graph'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite']]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards']
      TARGET:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESTarget'
        LABEL: 'Targets'
        PATH:'/chembl_target'
        MODEL: Target
        ID_COLUMN: Target.ID_COLUMN
        COLUMNS: Target.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
        COLUMNS_CARD: []
        ADDITIONAL_COLUMNS:[]
        FACETS: {}
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite']]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards']
      ASSAY:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESAssay'
        LABEL: 'Assays'
        PATH:'/chembl_assay'
        MODEL: Assay
        ID_COLUMN: Assay.ID_COLUMN
        COLUMNS: Assay.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
        COLUMNS_CARD: []
        ADDITIONAL_COLUMNS:[]
        FACETS: {}
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite']]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards']
      DOCUMENT:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESDocument'
        LABEL: 'Documents'
        PATH:'/chembl_document'
        MODEL: Document
        ID_COLUMN: Document.ID_COLUMN
        COLUMNS: Document.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
        COLUMNS_CARD: []
        ADDITIONAL_COLUMNS:[]
        FACETS: {}
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite']]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards']
      CELL_LINE:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESCellLine'
        LABEL: 'Cells'
        PATH:'/chembl_cell_line'
        MODEL: CellLine
        ID_COLUMN: CellLine.ID_COLUMN
        COLUMNS: CellLine.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
        COLUMNS_CARD: []
        ADDITIONAL_COLUMNS:[]
        FACETS: {}
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite']]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards']
      TISSUE:
        # KEY_NAME: Assigned after this declaration using the same string used for the key in ES_INDEXES
        ID_NAME: 'ESTissue'
        LABEL: 'Tissues'
        PATH:'/chembl_tissue'
        MODEL: glados.models.Tissue
        ID_COLUMN: glados.models.Tissue.ID_COLUMN
        COLUMNS: glados.models.Tissue.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        COLUMNS_CARD: []
        ADDITIONAL_COLUMNS:[]
        FACETS: {}
        DOWNLOAD_FORMATS: [glados.Settings.DEFAULT_FILE_FORMAT_NAMES['CSV'],
          glados.Settings.DEFAULT_FILE_FORMAT_NAMES['TSV']]
        AVAILABLE_VIEWS: [glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Table'],
          glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards'], glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Infinite']]
        DEFAULT_VIEW: glados.Settings.DEFAULT_RESULTS_VIEWS_NAMES['Cards']

    WS_COLLECTIONS:
      DRUG_LIST:
        MODEL: Compound
        BASE_URL: glados.Settings.WS_BASE_URL + 'molecule.json'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        ID_COLUMN: Compound.ID_COLUMN
        ADDITIONAL_COLUMNS:[]
      SUBSTRUCTURE_RESULTS_LIST:
        MODEL: Compound
        BASE_URL: 'base_url is set by initURL'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD
        ID_COLUMN: Compound.ID_COLUMN
        ADDITIONAL_COLUMNS:[]
      SIMILARITY_RESULTS_LIST:
        MODEL: Compound
        BASE_URL: 'base_url is set by initURL'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_SIMILARITY
        ID_COLUMN: Compound.ID_COLUMN
        ADDITIONAL_COLUMNS:[]
      COMPOUND_WS_RESULTS_LIST_CAROUSEL:
        MODEL: Compound
        BASE_URL: 'base_url is set by initURL'
        DEFAULT_PAGE_SIZE: "needs to be set up outside, for some reason it doesn't work"
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_REPORT_CARD_CAROUSEL
        ID_COLUMN: Compound.ID_COLUMN
        ADDITIONAL_COLUMNS:[]
        IS_CAROUSEL: true
      DOCS_BY_TERM_LIST:
        MODEL: Document
        BASE_URL: 'base_url is set by initURL'
        DEFAULT_PAGE_SIZE: glados.Settings.TABLE_PAGE_SIZES[2]
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        ID_COLUMN: Document.ID_COLUMN
        COLUMNS: Document.COLUMNS_SETTINGS.SEARCH_BY_TERM_RESULTS
        ADDITIONAL_COLUMNS:[]
    CLIENT_SIDE_WS_COLLECTIONS:
      # used for targets
      APPROVED_DRUGS_CLINICAL_CANDIDATES_LIST:
        MODEL: ApprovedDrugClinicalCandidate
        DEFAULT_PAGE_SIZE: 10
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        ID_COLUMN: ApprovedDrugClinicalCandidate.ID_COLUMN
        COLUMNS: ApprovedDrugClinicalCandidate.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
        ADDITIONAL_COLUMNS:[]
      # used for targets
      TARGET_RELATIONS_LIST:
        MODEL: TargetRelation
        DEFAULT_PAGE_SIZE: 5
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        ID_COLUMN: TargetRelation.ID_COLUMN
        COLUMNS: TargetRelation.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
        ADDITIONAL_COLUMNS:[]

      TARGET_COMPONENTS_LIST:
        MODEL: TargetComponent
        DEFAULT_PAGE_SIZE: 5
        AVAILABLE_PAGE_SIZES: glados.Settings.TABLE_PAGE_SIZES
        ID_COLUMN: TargetComponent.ID_COLUMN
        COLUMNS: Compound.COLUMNS_SETTINGS.RESULTS_LIST_TABLE
        ADDITIONAL_COLUMNS:[]

# fills the KEY_NAME for the ES_INDEXES object
for key_i, val_i of glados.models.paginatedCollections.Settings.ES_INDEXES
  val_i.KEY_NAME = key_i

# Loads the Search results URL's including the ElasticSearch entities configuration
glados.loadSearchResultsURLS()