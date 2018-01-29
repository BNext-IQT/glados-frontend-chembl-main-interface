describe 'Target Predictions', ->

  chemblID = 'CHEMBL25'
  compound = new Compound
    molecule_chembl_id: chemblID
    fetch_from_elastic: true

  beforeAll (done) ->

    dataURL = glados.Settings.STATIC_URL + 'testData/Compounds/CHEMBL25esResponse.json'
    $.get dataURL, (testData) ->
      esResponse = testData
      compound.set(compound.parse(esResponse))
      done()


  it 'is generated from a preloaded compound model', ->

    console.log 'compound: ', compound