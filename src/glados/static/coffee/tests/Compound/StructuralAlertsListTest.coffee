describe 'Compound Structural Alerts', ->

  it 'Sets up the url correctly', ->

    testChemblID = 'CHEMBL457419'
    structuralAlerts = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewStructuralAlertsList()
    structuralAlerts.initURL(testChemblID)

    urlMustBe = "#{glados.Settings.WS_BASE_URL}compound_structural_alert.json?molecule_chembl_id=#{testChemblID}&limit=10000"
    urlGot = structuralAlerts.url

    expect(urlMustBe).toBe(urlGot)

  sampleDataToParse = undefined

  testChemblID = undefined
  structuralAlerts = undefined

  beforeAll (done) ->

    testChemblID = 'CHEMBL457419'
    structuralAlerts = glados.models.paginatedCollections.PaginatedCollectionFactory.getNewStructuralAlertsList()
    structuralAlerts.initURL(testChemblID)

    dataURL = glados.Settings.STATIC_URL + 'testData/Compounds/StructuralAlerts/sampleDataToParseCHEMBL457419.json'
    $.get dataURL, (testData) ->
      sampleDataToParse = testData
      done()

  it 'parses the data correctly', ->

    console.log 'sampleDataToParse: ', sampleDataToParse
    parsedDataGot = structuralAlerts.parse(sampleDataToParse)
    console.log 'parsedDataGot: ', parsedDataGot
