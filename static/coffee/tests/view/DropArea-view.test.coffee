define [
  "view/DropArea-view"  
  "model/DropArea-model"
  "collection/DropArea-collection"
],(DropAreaView, DropAreaModel, DropAreaCollection)->

  describe "DropArea View",->

    beforeEach ->
      @model = new DropAreaModel()
      @collection = new DropAreaCollection([
        new DropAreaModel(),
        new DropAreaModel(),
        new DropAreaModel(),
      ])

      @service =
        renderFormViewElement:(row)->
          $("<div>").html """
          <div data-drop-accept>DATA</div>
          <div data-html-row></div>
          <span data-js-close-area></span>
          <span data-js-options-area></span>
          """

        getOrAddFormItemView: (model)=>
          view = new ->
            $el:$("<div>")
            model: model
            render:->
              @$el.html("testForm")
            remove:->@bRemove=true
            bRemove:false

          view.$el.data DATA_VIEW, view
          view

      @row = 0
      @view = new DropAreaView
        collection: @collection
        service: @service
        row: @row
    
    afterEach ->
      @view.remove()
      delete @model
      delete @service
      delete @view
      delete @row

    it "check initialize", ->      
      expect(@view.$area?).toBeTruthy()
      expect(@view.row).toEqual(@row)
      expect(@view.$area.html()).toEqual("DATA")
      expect(@view.getFluentMode()).toBeFalsy()

    it "check setRow", ->
      bReindex = false
      @view.reindex = -> bReindex = true
      @view.setRow(@row+1)
      expect(@view.row).toEqual(@row+1)
      expect(bReindex).toBeTruthy()
      expect(@view.$el.find("[data-html-row]").html()).toMatch(new RegExp("#{@row+1}"))

    it "check render", ->
      @view.render()
      expect(@collection.models.length).toEqual(3)      
      expect(@service.getOrAddFormItemView(@model).model).toEqual(@model)
      expect(@view.$area.children().length).toEqual(3)
      expect(@view.$area.children().get(0).innerHTML).toEqual("testForm")

    it "check reindex", ->
      expect(@collection.models.length).toEqual(3)      
      expect(@collection.models[0].get("position")).toEqual(0)
      expect(@collection.models[1].get("position")).toEqual(0)
      expect(@collection.models[2].get("position")).toEqual(0)
      @view.render()
      @view.reindex()
      expect(@collection.models[0].get("position")).toEqual(0)
      expect(@collection.models[1].get("position")).toEqual(1)
      expect(@collection.models[2].get("position")).toEqual(2)

    it "check event_close",->
      @view.render()
      bRemoveAfterClose = false      
      @view.remove = -> bRemoveAfterClose = true      
      @view.$el.find("[data-js-close-area]").click()
      expect(bRemoveAfterClose).toBeTruthy()
      expect(@view.$area.children().length).toEqual(3)
      expect($(@view.$area.children()[0]).data(DATA_VIEW).bRemove).toBeTruthy()
      expect($(@view.$area.children()[1]).data(DATA_VIEW).bRemove).toBeTruthy()
      expect($(@view.$area.children()[2]).data(DATA_VIEW).bRemove).toBeTruthy()
    
    it "check setFluentViewMode",->
      paramAxis = ""
      @view.setAxis = (axis)-> paramAxis = axis
      @view.render()
      #expect(paramAxis).toEqual("y")
      expect(@view.getFluentMode()).toEqual(false)
      $children = @view.$area.children()
      expect($children.length).toEqual(3)
      expect( @view.$el.hasClass("form-horizontal")).toBeTruthy()
      models = @view.collection.where row: @view.row    
      @view.setFluentViewMode(true)
      #expect(paramAxis).toEqual("x")
      expect(@view.getFluentMode()).toEqual(true)
      expect(not @view.$el.hasClass("form-horizontal")).toBeTruthy()

    it "check event_options",->
      @view.render()      
      bCallFluentMode = false
      bParamFluentMode = false
      @view.setFluentViewMode = (mode)=>
        bCallFluentMode = true
        bParamFluentMode = (mode is not @view.getFluentMode())
      @view.$el.find("[data-js-options-area]").click()
      expect(bCallFluentMode).toBeTruthy()
      expect(bParamFluentMode).toBeTruthy()

    it "check getDirection",->
      @view.render()          
      expect(@view.getFluentMode()).toEqual(false)
      expect(@view.getDirection()).toEqual("horizontal")
      bCallSmartSliceNormalize = false
      bRow = false
      bKey = false
      bBaseValue = false
      @view.collection.smartSliceNormalize = (row, key, baseValue)=>
        bCallSmartSliceNormalize = true
        bRow = row is @view.row
        bKey = key is "direction"
        bBaseValue = baseValue is @view.getDirection()        
      @view.setFluentViewMode true
      expect(bCallSmartSliceNormalize).toBeTruthy()
      expect(bRow).toBeTruthy()
      expect(bKey).toBeTruthy()
      expect(bBaseValue).toBeTruthy()

    it "check setDirection",->
      expect(@view.getFluentMode()).toEqual(false)
      @view.setDirection "vertical"
      expect(@view.getFluentMode()).toEqual(true)
      @view.setDirection "horizontal"
      expect(@view.getFluentMode()).toEqual(false)
      @view.setDirection "junk"
      expect(@view.getFluentMode()).toEqual(false)

    xit "check setAxis",->
      expect(@view.setAxis("x")).toBeTruthy()
      expect(@view.setAxis("y")).toBeTruthy()
      expect(@view.setAxis("")).toBeFalsy()


