define [
  "model/DropArea-model",
  "collection/DropArea-collection"
],(DropAreaModel,DropAreaCollection)->
  respond2 = [{
    label:"one"
    placeholder:"two"
    type:"input1"
    name:"three"
    help:"one"
    position:"1"
    row:2
  },{
    label:"one"
    placeholder:"two"
    type:"input1"
    name:"three"
    help:"one"
    position:"1"
    row:1
  }]

  describe "Test collection",->
    beforeEach ->
      @server = sinon.fakeServer.create()
      @collection = new DropAreaCollection
        url:"/forms1.json"
    
    afterEach ->
      @server.restore()
      delete @collection
    
    it "initialize",->
      expect(@collection.models.length).toEqual(1)

    it "fetch data",->      
      @server.respondWith "GET","/forms1.json",[
        200,{"Content-Type":"application/json"}, JSON.stringify respond2
      ]
      
      @collection.fetch()
      @server.respond()     
      expect(@collection.models.length).toEqual(2)
      model = @collection.models[0]
      expect(model.get("label")).toEqual("one")
      expect(model.get("placeholder")).toEqual("two")
      expect(model.get("type")).toEqual("input1")
      expect(model.get("name")).toEqual("three")
      expect(model.get("help")).toEqual("one")
      expect(model.get("position")).toEqual(1)
      expect(model.get("row")).toEqual(0)

    it "Collection updateAll",->
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
      expect(request.url).toEqual("/forms1.json")
      expect(request.requestBody).toEqual(
        JSON.stringify(@collection.toJSON())
      )

    it "Collection parce",->
      expect(respond2.length).toEqual(2)
      expect(respond2[0].row).toEqual(2)
      expect(respond2[1].row).toEqual(1)
      respond = @collection.parse respond2
      expect(respond[0].row).toEqual(0)
      expect(respond[1].row).toEqual(1)



