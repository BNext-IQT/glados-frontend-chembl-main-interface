glados.useNameSpace 'glados.models.paginatedCollections.esSchema',
  # --------------------------------------------------------------------------------------------------------------------
  # Elastic Search Document Schema
  # --------------------------------------------------------------------------------------------------------------------
  DocumentSchema:
    FACETS_GROUPS: glados.models.paginatedCollections.esSchema.FacetingHandler.generateFacetsForIndex(
      'chembl_document'
      # Default Selected
      [
        'doc_type',
        {
          property:'journal'
          sort:'asc'
          intervals: 20
        },
        {
          property:'_metadata.source.src_description'
          sort:'asc'
          intervals: 20
        },
        'year',
      ],
      # Default Hidden
      [
      ],
      [

      ]
    )
