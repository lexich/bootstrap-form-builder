define [
 "view/FormItem-view"
 "model/DropArea-model"
],(FormItemView, DropAreaModel)->

  describe "FormItemView",->
    beforeEach ->
      @model = new DropAreaModel
        direction: "horizontal"
        help: "help"
        label: "input"
        name: "input"
        placeholder: "input"
        position: 0
        row: 0
        size: 3
        type: "input"
      @service =
        getTemplate:(type)->
          """
          <div class="control-group">
          <label class="control-label" for="<%= type %>"><%= label %></label>
          <div class="controls">
          <input type="text" id="<%= type %>" name="<%= name %>" placeholder="<%= placeholder %>">
          <p class="help-block valtype" data-valtype="help"><%= help %></p>
          </div>
          <a data-js-close />
          <a data-js-options />
          <a data-js-inc-size />
          <a data-js-dec-size />
          </div>
          """

        renderFormItemTemplate:(html)->
          templateHtml = "<%= content %>"
          _.template templateHtml, content:html

      @view = new FormItemView
        model:@model
        service: @service

      @model.trigger "change"

    afterEach ->
      @view.remove()
      delete @view
      @model.destroy()
      delete @model
      delete @service

    it "check render",->
      expect(@view.$el.children().length).toEqual 1
      expect(@view.$el.find("input[id='#{@model.get("type")}']").length).toEqual(1)

    it "check remove",->
      bDestroy = false
      @model.destroy = ->
        bDestroy = true
      @view.remove()
      expect(bDestroy).toBeTruthy()

    it "check event_close",->
      bRemove = false
      @view.remove = ->
        bRemove = true
      @view.$el.find("[data-js-close]").click()
      expect(bRemove).toBeTruthy()

    it "check cleanSize",->
      @view.$el.addClass("span4")
      @view.cleanSize(@view.$el)
      expect(@view.$el.hasClass("span4")).toBeFalsy()
      @view.$el.addClass("span")
      @view.cleanSize(@view.$el)
      expect(@view.$el.hasClass("span")).toBeTruthy()

    it "check updateSize",->
      size = @model.get('size')
      expect(@model.get("direction")).toEqual("horizontal")
      @view.updateSize()
      expect(@view.$el.hasClass("span#{size}")).toBeFalsy()
      @model.set("direction","vertical", silent:true)
      @view.updateSize()
      expect(@view.$el.hasClass("span#{size}")).toBeTruthy()

    it "check event_inc, event_dec",->
      expect(@model.get('size')).toEqual(3)
      @view.$el.find("[data-js-inc-size]").click()
      expect(@model.get('size')).toEqual(4)
      @view.$el.find("[data-js-dec-size]").click()
      expect(@model.get('size')).toEqual(3)
      @model.set "size", 1
      @view.$el.find("[data-js-dec-size]").click()
      expect(@model.get('size')).toEqual(1)
      @model.set "size", 12
      @view.$el.find("[data-js-inc-size]").click()
      expect(@model.get('size')).toEqual(12)

    it "check event options",->
      bShowModal = false
      @service.showModal = ->
        bShowModal = true
      @view.$el.find("[data-js-options]").click()
      expect(bShowModal).toBeTruthy()