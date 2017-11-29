glados.useNameSpace 'glados.models.Compound',
  Metabolism: Backbone.Model.extend

    initialize: ->
      @url = glados.models.paginatedCollections.Settings.ES_BASE_URL +
      '/chembl_metabolism/_search?q=drug_chembl_id:' + @get('molecule_chembl_id') + '&size=10000'

    #-------------------------------------------------------------------------------------------------------------------
    # Parsing
    #-------------------------------------------------------------------------------------------------------------------
    addNode: (chemblID, selectedID, nodesList, nodesToPosition) ->

      newNode =
        chembl_id: chemblID
        pref_name: 'Name!!!'
        has_structure: true
        is_current: chemblID == selectedID

      nodesList.push newNode
      nodesToPosition[chemblID] = nodesList.length - 1

    parse: (response) ->

      parsed =
        graph:
          nodes: []
          edges: []

      selectedChemblID = @get('molecule_chembl_id')
      metabolisms = response.hits.hits
      console.log 'metabolisms: ',  metabolisms
      nodesToPosition = {}
      nodesList = parsed.graph.nodes
      for metabolism in metabolisms

        metData = metabolism._source

        substrateID = metData.substrate_chembl_id
        if not nodesToPosition[substrateID]?
          @addNode(substrateID, selectedChemblID, nodesList, nodesToPosition)

        metaboliteID = metData.metabolite_chembl_id
        if not nodesToPosition[metaboliteID]?
          @addNode(metaboliteID, selectedChemblID, nodesList, nodesToPosition)

        newEdge =
          enzyme: metData.enzyme_name
          source: nodesToPosition[substrateID]
          target: nodesToPosition[metaboliteID]
          met_conversion: metData.met_conversion
          organism: metData.organism
          doc_chembl_id: 'CHEMBL3544494'
          enzyme_chembl_id: metData.enzyme_chembl_id
          references_list: (ref.ref_url for ref in metData.metabolism_refs).join("|")

        parsed.graph.edges.push newEdge

      return parsed