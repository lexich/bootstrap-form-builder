define [
  "view/Form-view"
  "collection/FormItem-collection"
],(FormView, FormItemCollection)->

  describe "FormView",->
    respond = items:[{
      label:"one"
      placeholder:"two"
      type:"input1"
      name:"three"
      help:"one"
      position:"1"
      row:2
      fieldset:1
    },{
      label:"one"
      placeholder:"two"
      type:"input1"
      name:"three"
      help:"one"
      position:"1"
      row:1
      fieldset:0
    }]

    beforeEach ->
      @server = sinon.fakeServer.create()          
      @server.respondWith "GET","/form.json",[
        200,{"Content-Type":"application/json"}, JSON.stringify respond
      ]
      service = {
        getTemplate:-> ""
      }
      @collection = new FormItemCollection
        url:"/form.json"
        service:service
      @view = new FormView
        collection:@collection
      @view.el.id = "testid"

    afterEach ->
      @view.remove()
      @server.restore()
      delete @view
      delete @collection

    it "check initialize",->
      bRender = false
      @view.render  = -> bRender = true
      @collection.fetch()
      @server.respond()
      expect(@collection.models.length).toEqual(2)
      expect(bRender).toBeTruthy()

    it "on_collection_reset",->
      nCounter = 0
      @view.reinitialize = ->
        nCounter += 1
      @view.render = ->
        nCounter *= 2
      @collection.fetch()
      @server.respond()
      expect(nCounter).toEqual(2)

    it "check getOrAddFieldsetView",->
      aRows = []
      bCheckPlaceholder = true
      
      @view.getOrAddFieldsetView = (row, $placeholder)=>
        aRows.push row

      @collection.fetch()
      @server.respond()
      expect(aRows.length).toEqual(2)
      expect(aRows).toContain(0)
      expect(aRows).toContain(1)
      expect(bCheckPlaceholder).toBeTruthy()
