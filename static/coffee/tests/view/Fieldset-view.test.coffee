define [
  "underscore"
  "view/Fieldset-view"
  "collection/FormItem-collection"
], (_, FieldsetView, FormItemCollection)->

  describe "FieldsetView", ->
    beforeEach ->
      collection = new FormItemCollection

      model = collection.getOrAddFieldsetModel(0)
      @view = new FieldsetView {model, collection}

    afterEach ->
      @view.remove()

    it "insertRow", ->
      bGet = false
      @view.getOrAddRowView = ->
        bGet = true
      @view.insertRow(8)
      expect(bGet).toBeTruthy()

    it "getRowByPosition", ->
      newRow = @view.insertRow(2)
      findRow = @view.getRowByPosition(2)
      expect(newRow).toEqual findRow
      findRow2 = @view.getRowByPosition(9)
      expect(findRow2).toEqual null

    it "getOrAddRowView", ->
      expect(_.size(@view.childrenViews)).toEqual 0
      view1 = @view.getOrAddRowView(1)
      expect(_.size(@view.childrenViews)).toEqual 1
      view2 = @view.getOrAddRowView(1)
      expect(_.size(@view.childrenViews)).toEqual 1
      expect(view1).toEqual view2

    it "isVisibleDirection", ->
      view1 = @view.getOrAddRowView(1)
      bIsVisibleDirection = false
      view1.isVisibleDirection = ->
        bIsVisibleDirection = true
        true
      expect(@view.isVisibleDirection()).toBeTruthy()
      expect(bIsVisibleDirection).toBeTruthy()
      view2 = @view.getOrAddRowView(2)
      view2.isVisibleDirection = ->
        false
      expect(@view.isVisibleDirection()).toBeFalsy()

    it "updateDirectionVisible", ->
      @view.$el.append $("<div>").attr("data-js-fieldset-position","1")
      @view.isVisibleDirection = -> false
      expect(@view.getItem("direction").length).toEqual 1
      expect(@view.getItem("direction").hasClass("hide")).toBeFalsy()
      @view.updateDirectionVisible()
      expect(@view.getItem("direction").hasClass("hide")).toBeTruthy()
      @view.isVisibleDirection = -> true
      @view.updateDirectionVisible()
      expect(@view.getItem("direction").hasClass("hide")).toBeFalsy()


    it "on_model_change", ->
      bRender = false
      @view.render = ->
        bRender = true
      @view.model.set "title", "testTitle", {validate: true}
      expect(bRender).toBeTruthy()


    it "clicks", ->
      $el = @view.$el
      @view.render = ->
        FieldsetView::render.apply this, arguments
        $el.append $("<div>").html """
                     <div data-js-remove-fieldset></div>
                     <div contenteditable data-bind></div>
                     <div data-js-fieldset-position></div>
                     """
      @view.render()
      direction = @view.model.get('direction')
      @view.$el.find("[data-js-fieldset-position]").trigger("click")
      expect(direction).not.toEqual(@view.model.get('direction'))

      $input = @view.$el.find("[contenteditable][data-bind]")
      title = "testTitle"
      $input.text(title)
      $input.trigger("input")
      expect(@view.model.get("title")).toEqual title

      bRemove = false
      @view.remove = -> bRemove = true
      @view.$el.find("[data-js-remove-fieldset]").trigger("click")
      expect(bRemove).toBeTruthy()


