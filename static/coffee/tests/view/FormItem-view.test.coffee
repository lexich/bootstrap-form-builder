define [
 "view/FormItem-view"
 "model/FormItem-model"
],(FormItemView, FormItemModel)->

  describe "FormItemView",->
    beforeEach ->
      @model = new FormItemModel
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


    it "check remove",->
      bDestroy = false
      @model.destroy = ->
        bDestroy = true
      @view.remove()
      expect(bDestroy).toBeTruthy()


    it "check updateSize",->
      size = @model.get('size')
      expect(@model.get("direction")).toEqual("horizontal")
      @view.updateSize()
      expect(@view.$el.hasClass("span#{size}")).toBeFalsy()
      @model.set("direction","vertical", silent:true)
      @view.updateSize()
      expect(@view.$el.hasClass("span#{size}")).toBeTruthy()
