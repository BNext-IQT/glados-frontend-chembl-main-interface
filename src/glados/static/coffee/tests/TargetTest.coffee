describe "Target", ->

  describe "Target Model", ->

    target = new Target
        target_chembl_id: 'CHEMBL2363965'

    beforeAll (done) ->
      target.fetch()

      # this timeout is to give time to get the
      # target classification information, it happens after the fetch,
      # there is a way to know that it loaded at least one classification: get('protein_classifications_loaded')
      # but there is no way to know that it loaded all the classifications.
      setTimeout ( ->
        done()
      ), 10000

    it "(SERVER DEPENDENT) loads the protein target classification", (done) ->
      classification = target.get('protein_classifications')
      class1 = classification[8][0]
      class2 = classification[601][0]
      expect(class1).toBe('Other cytosolic protein')
      expect(class2).toBe('Unclassified protein')

      done()

  describe "Associated Compounds", ->

    associatedCompounds = undefined
    currentXAxisProperty = undefined
    minMaxTestData = undefined

    beforeAll (done) ->

      associatedCompounds = new glados.models.Target.TargetAssociatedCompounds
        target_chembl_id: 'CHEMBL2111342'

      currentXAxisProperty = 'molecule_properties.full_mwt'
      associatedCompounds.set('current_xaxis_property', currentXAxisProperty)

      $.get (glados.Settings.STATIC_URL + 'testData/AssociatedCompundsMinMaxSampleResponse.json'), (testData) ->
        minMaxTestData = testData
        done()


    it 'Generates the request data to get min and max', ->

      requestData = associatedCompounds.getRequestMinMaxData()
      expect(requestData.aggs.max_agg.max.field).toBe(currentXAxisProperty)
      expect(requestData.aggs.min_agg.min.field).toBe(currentXAxisProperty)

    it 'Parses the min and max data', ->
      parsedObj = associatedCompounds.parseMinMax(minMaxTestData)
      expect(parsedObj.max_value).toBe(13020.3)
      expect(parsedObj.min_value).toBe(4)

    it 'Generates the request data', ->
      console.log 'GENERATING REQUEST DATA!'