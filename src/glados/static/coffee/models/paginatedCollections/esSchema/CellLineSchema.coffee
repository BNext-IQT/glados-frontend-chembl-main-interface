glados.useNameSpace 'glados.models.paginatedCollections.esSchema',
  # --------------------------------------------------------------------------------------------------------------------
  # Elastic Search Target Schema
  # --------------------------------------------------------------------------------------------------------------------
  CellLineSchema:
    FACETS_GROUPS: glados.models.paginatedCollections.esSchema.FacetingHandler.generateFacetsForIndex(
      'chembl_cell_line'
      # Default Selected
      [
        'cell_source_tissue',
        '_metadata.organism_taxonomy.l1',
        '_metadata.organism_taxonomy.l2',
        '_metadata.organism_taxonomy.l3',
        {
          property:'cell_source_organism'
          sort:'asc'
          intervals: 20
        },
      ],
      # Default Hidden
      [
      ],
      [

      ]
    )
