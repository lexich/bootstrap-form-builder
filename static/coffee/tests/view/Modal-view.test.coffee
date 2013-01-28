define [
  "view/Modal-view"
],(ModalView)->

  describe "ModalView Generator",->
    beforeEach ->
      @preRender = (->)
      @preSave = (->)
      @view = new ModalView        
    
    afterEach ->
      delete @preRender
      delete @preSave
      @view.remove()

    it "check wrappper",->
      expect(@view.$el.is(":visible")).toBeFalsy()
      expect(@view.el.tagName).toEqual("DIV")
      expect(@view.$el.hasClass("modal-wrapper")).toBeTruthy()

    it "check render",->
      bPreRenderCall = false
      view = @view
      @view.callback_preRender = ($el,$body)->
        bPreRenderCall = true
        expect(arguments.length).toEqual(2)
        expect($el[0]==view.el).toBeTruthy()
        $tBody = view.$el.find(view.options.classModalBody)
        expect($tBody.length).toEqual(1)
        expect($body[0]==$tBody[0]).toBeTruthy()

      @view.render()
      expect(bPreRenderCall).toBeTruthy()

    it "check show",->
      view = @view
      bPreRender = false
      bPreSave = false

      preRender = ($el,$body)->
        bPreRender = true

      postSave = ($el, $body)->
        bPreSave = true
        expect(arguments.length).toEqual(2)
        expect($el[0]==view.el).toBeTruthy()
        $tBody = view.$el.find(view.options.classModalBody)
        expect($tBody.length).toEqual(1)
        expect($body[0]==$tBody[0]).toBeTruthy()

      @view.show
        preRender: preRender
        postSave: postSave

      expect(bPreRender).toBeTruthy()
      view.$el.find("[data-js-save]").click()
      expect(bPreSave).toBeTruthy()