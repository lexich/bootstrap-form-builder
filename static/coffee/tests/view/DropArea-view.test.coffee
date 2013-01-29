define [
  "view/DropArea-view"  
  "model/DropArea-model"
],(DropAreaView, DropAreaModel)->

  describe "DropArea View",->

    beforeEach ->
      @model = new DropAreaModel()
      @collection = 
        models: [
          new DropAreaModel(),
          new DropAreaModel(),
          new DropAreaModel(),
        ],
        where:-> @models

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

      @row = 1
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
    
    xit "checl event_options",->
      @view.render()
      @view.$el.find("[data-js-options-area]").click()
