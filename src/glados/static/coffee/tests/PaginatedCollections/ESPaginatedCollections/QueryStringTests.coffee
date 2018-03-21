describe "An elasticsearch collection initialised from a custom querystring", ->

  customQueryString = 'target_chembl_id:CHEMBL2093868 AND ' +
    'standard_type:(IC50 OR Ki OR EC50 OR Kd) AND _exists_:standard_value AND _exists_:ligand_efficiency'
  esList = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewESActivitiesList(customQueryString)

  it 'Sets initial parameters', ->
    expect(esList.getMeta('id_name')).toBe("ESActivitity")
    expect(esList.getMeta('index')).toBe("/chembl_activity")
    expect(esList.getMeta('key_name')).toBe("ACTIVITY")
    expect(esList.getMeta('custom_query_string')).toBe(customQueryString)

  it 'Generates the correct request object', ->

    requestData = esList.getRequestData()
    expect(requestData.query.bool.must[0].query_string.query).toBe(customQueryString)

  it 'generates a state object', ->

    state = esList.getStateJSON()

    pathInSettingsMustBe = 'ES_INDEXES_NO_MAIN_SEARCH.ACTIVITY'
    expect(state.settings_path).toBe(pathInSettingsMustBe)
    queryStringMustBe = customQueryString
    expect(state.custom_query_string).toBe(queryStringMustBe)
    expect(state.use_custom_query_string).toBe(true)

  it 'creates a list from a state object', -> TestsUtils.testRestoredListIsEqualToOriginal(esList)