define [
  "view/Form-view"
  "collection/FormItem-collection"
],(FormView, FormItemCollection)->

  describe "FormView",->
    respond = [{
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

    beforeEach ->
      @server = sinon.fakeServer.create()          
      @server.respondWith "GET","/form.json",[
        200,{"Content-Type":"application/json"}, JSON.stringify respond
      ]
      
      @collection = new FormItemCollection
        url:"/form.json"        
      @view = new FormView
        collection:@collection
      @view.el.id = "testid"

    afterEach ->
      @view.remove()
      @server.restore()
      delete @view
      @collection.remove()
      delete @collection

    it "check initialize",->
      bRender = false
      @view.render  = -> bRender = true
      @collection.fetch()
      @server.respond()
      expect(@collection.models.length).toEqual(2)
      expect(bRender).toBeTruthy()

    it "check renderRow",->
      aRows = []
      @view.renderRow = (row)-> aRows.push row
      @collection.fetch()
      @server.respond()
      expect(aRows.length).toEqual(2)
      expect(aRows).toContain(0)
      expect(aRows).toContain(1)
      expect(aRows[0]).toEqual(0)
      expect(aRows[1]).toEqual(1)

    it "check getOrAddDropArea after renderRow",->
      aRows = []
      bCheckPlaceholder = true
      
      @view.getOrAddDropArea = (row, $placeholder)=> 
        aRows.push row
        bCheckPlaceholder &= $placeholder.parents("#testid").length is 1          
        render:->

      @collection.fetch()
      @server.respond()
      expect(aRows.length).toEqual(2)
      expect(aRows).toContain(0)
      expect(aRows).toContain(1)
      expect(bCheckPlaceholder).toBeTruthy()

    it "check DOM",->
      @collection.fetch()
      @server.respond()
      $placeholder = @view.getPlaceholder()
      expect($placeholder.parents("#testid").length).toEqual(1)
      expect($placeholder.children().length).toEqual(2)

    it "event_submitForm",->
      @collection.fetch()
      @server.respond()
      bUpdateAll = false
      @collection.updateAll = -> 
        bUpdateAll = true
      @view.$el.find("[data-js-submit-form]").click()
      expect(bUpdateAll).toBeTruthy()

    it "event_addDropArea",->
      @collection.fetch()
      @server.respond()
      expect(_.size(@view.dropAreas)).toEqual(2)
      oldMax = parseInt _.chain(@view.dropAreas).keys().max().value()
      @view.$el.find("[data-js-add-drop-area]").click()
      max = parseInt _.chain(@view.dropAreas).keys().max().value()
      expect(_.size(@view.dropAreas)).toEqual(3)
      expect(max).toEqual(oldMax+1)

    it "removeDropArea",->
      expect(@collection.models.length).toEqual(1)
      @collection.fetch()
      @server.respond()
      size = _.size(@view.dropAreas)
      expect(size).toEqual(2)
      keys = _.keys @view.dropAreas
      expect(@view.removeDropArea(keys[0])).toBeTruthy()
      expect(_.size(@view.dropAreas)).toEqual(size-1)

      