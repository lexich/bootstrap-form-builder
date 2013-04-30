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
          </div>
          """

      @view = new FormItemView
        model:@model
        service: @service

      @model.trigger "change"

    afterEach ->
      @view.remove()
      delete @view
      delete @model
      delete @service


    it "check remove",->
      bDestroy = false
      bWire = false
      @view.model.destroy = ->
        bDestroy = true
      @view.unbindWireEvents = ->
        bWire = true
      @view.remove()
      expect(bDestroy).toBeTruthy()
      expect(bWire).toBeTruthy()

    it "check on_model_change",->
      bOnChange = false
      @view.render = ->
        bOnChange = true
      @model.set "help","1"
      expect(bOnChange).toBeTruthy()

    it 'check events',->
      bDecSize = false
      bIncSize = false
      bRemove = false
      bEditable = false
      View = FormItemView.extend
        event_decsize:-> bDecSize = true
        event_incsize:-> bIncSize = true
        event_remove :-> bRemove = true
        event_clickEditable:-> bEditable = true
      view = new View
        model:@model
        service: @service

      view.render()
      $dec = view.$el.find("[data-js-formitem-decsize]")
      expect($dec.length).toEqual 1
      $dec.click()
      expect(bDecSize).toBeTruthy()

      $inc = view.$el.find("[data-js-formitem-incsize]")
      expect($inc.length).toEqual 1
      $inc.click()
      expect(bIncSize).toBeTruthy()

      $rem = view.$el.find("[data-js-formitem-remove]")
      expect($rem.length).toEqual 1
      $rem.click()
      expect(bRemove).toBeTruthy()

      view.$el.click()
      expect(bEditable).toBeTruthy()
      view.remove()

    it 'check data:size',->
      size = @view.model.get("size")
      expect(size).toEqual 3
      @view.$el.find("[data-js-formitem-decsize]").click()
      expect(@view.model.get("size")).toEqual size - 1
      @view.$el.find("[data-js-formitem-incsize]").click()
      expect(@view.model.get("size")).toEqual size

      bRemove = false
      @view.remove = -> bRemove = true
      @view.$el.find("[data-js-formitem-remove]").click()
      expect(bRemove).toBeTruthy()