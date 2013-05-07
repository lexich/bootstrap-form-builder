define [
  "underscore"
  "view/NotVisual-view"
  "collection/FormItem-collection"
], (_, NotVisualView, FormItemCollection)->
  describe "NotVisualView",->
    beforeEach ->
      service = {}
      collection = new FormItemCollection
        url:"/form.json"
        service:service

      @view = new NotVisualView {collection, service}

    afterEach ->
      @view.remove()
      @view.collection.reset()
      delete @view

    it "on_collection_reset",->
      bReinitialize = false
      @view.reinitialize = -> bReinitialize = true
      bRender = false
      @view.render = -> bRender = true
      @view.collection.reset()
      expect(bReinitialize).toBeTruthy()
      expect(bRender).toBeTruthy()

    it "getOrAddViewByModel", ->
      expect(_.size(@view.childrenViews)).toEqual 0
      model = @view.collection.addNotVisualModel {}
      view = @view.getOrAddViewByModel model
      expect(view).not.toEqual null
      expect(_.size(@view.childrenViews)).toEqual 1
      view2 = @view.getOrAddViewByModel model
      expect(view2).not.toEqual null
      expect(_.size(@view.childrenViews)).toEqual 1

    it "reinitialize",->
      expect(_.size(@view.childrenViews)).toEqual 0
      size = _.size(@view.collection.notVisualCollection.models)
      @view.reinitialize()
      expect(_.size(@view.childrenViews)).toEqual size
      model = @view.collection.addNotVisualModel {}
      @view.reinitialize()
      expect(_.size(@view.childrenViews)).toEqual size + 1
      @view.collection.remove model
      @view.reinitialize()
      expect(_.size(@view.childrenViews)).toEqual size
