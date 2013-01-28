define [
  "model/DropArea-model",
  "collection/DropArea-collection"
],(DropAreaModel,DropAreaCollection)->
  describe "Test collection",->
    beforeEach ->
      @server = sinon.fakeServer.create()
      @collection = new DropAreaCollection()      
    afterEach ->
      @server.restore()
    
    it "fetch data",->
      respond = JSON.stringify
        label:"one"
        placeholder:"two"
        type:"input1"
        name:"three"
        help:"one"
        position:"1"
        row:2
      
      @server.respondWith "GET","/forms.json",[
        200,{"Content-Type":"application/json"},respond
      ]
      
      @collection.fetch()
      @server.respond()     
      expect(@collection.models.length).toEqual(1)
      model = @collection.models[0]
      expect(model.get("label")).toEqual("one")
      expect(model.get("placeholder")).toEqual("two")
      expect(model.get("type")).toEqual("input1")
      expect(model.get("name")).toEqual("three")
      expect(model.get("help")).toEqual("one")
      expect(model.get("position")).toEqual(1)
      expect(model.get("row")).toEqual(2)

    it "updateAllData",->
      sinon.spy()   
      model = new DropAreaModel
        label:"one"
        placeholder:"two"
        type:"input1"
        name:"three"
        help:"one"
        position:"1"
        row:2
      @collection.push model
      @collection.updateAll()

      expect(@server.requests.length).toEqual(1)
      request = @server.requests[0]
      expect(request.method).toEqual("POST")
      expect(request.url).toEqual("/forms.json")
      expect(request.requestBody).toEqual(
        JSON.stringify(@collection.toJSON())
      )

