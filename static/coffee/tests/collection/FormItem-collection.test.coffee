define [
  "model/FormItem-model",
  "collection/FormItem-collection"
],(FormItemModel,FormItemCollection)->
  respond = items: [{
    label:"one"
    placeholder:"two"
    type:"input1"
    name:"three"
    help:"one"
    position:"2"
    row:2,
    fieldset:0
    direction:"horizontal"
  },{
    label:"one"
    placeholder:"two"
    type:"input1"
    name:"three"
    help:"one"
    position:"1"
    row:1
    fieldset:0
    direction:"vertical"
  },{
    label:"one"
    placeholder:"two"
    type:"input1"
    name:"three"
    help:"one"
    position:"1"
    row:1
    fieldset:1
    direction:"horizontal"
  }],fieldsets:[{
    direction:"horizontal"
  }],notvisual:[{
    direction:"horizontal"
  }],rows:[{
    test:"test"
  }]

  describe "FormItemcollection",->
    beforeEach ->
      @server = sinon.fakeServer.create()
      @server.respondWith "GET","/forms1.json",[
        200,{"Content-Type":"application/json"}, JSON.stringify respond
      ]
      @collection = new FormItemCollection
        url:"/forms1.json"
    
    afterEach ->
      @server.restore()
      delete @collection
    
    it "initialize",->
      expect(@collection.models.length).toEqual(1)

    it "fetch data",->      
      
      @collection.fetch()
      @server.respond()
      expect(@collection.models.length).toEqual(3)
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
      model = new FormItemModel
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
      items = respond.items
      expect(items.length).toEqual(3)
      expect(items[0].row).toEqual(2)
      expect(items[1].row).toEqual(1)
      expect(items[1].row).toEqual(1)
      resp = @collection.parse respond
      items = resp.items
      expect(resp[0].row).toEqual(0)
      expect(resp[1].row).toEqual(0)
      expect(resp[2].row).toEqual(1)

    it "toJson",->
      json = @collection.toJSON()
      expect(json.items?).toBeTruthy()
      expect(json.rows?).toBeTruthy()
      expect(json.fieldsets?).toBeTruthy()
      expect(json.notvisual?).toBeTruthy()

    it "get other collections",->
      @collection.fetch()
      @server.respond()
      expect(@collection.models.length).toEqual 3
      rows = @collection.getRow(0,1)
      expect(rows.length).toEqual(1)
      fieldset = @collection.getFieldset(0)
      expect(fieldset.length).toEqual(2)
      fieldsetGroup = @collection.getFieldsetGroupByRow(0)
      expect(_.keys(fieldsetGroup).length).toEqual 2

    it "getOrAdd methods",->
      @collection.fetch()
      @server.respond()

      if models = @collection.fieldsetCollection.models
        len = models.length
        @collection.getOrAddFieldsetModel(9)
        expect(models.length).toEqual len + 1
        @collection.getOrAddFieldsetModel(9)
        expect(models.length).toEqual len + 1

      if models = @collection.rowCollection.models
        len = models.length
        @collection.getOrAddRowModel(9,9)
        expect(models.length).toEqual len + 1
        @collection.getOrAddRowModel(9,9)
        expect(models.length).toEqual len + 1

      if models = @collection.notVisualCollection.models
        len = models.length
        @collection.addNotVisualModel({data:"test"})
        expect(models.length).toEqual len + 1
        @collection.addNotVisualModel({data:"test"})
        expect(models.length).toEqual len + 2


