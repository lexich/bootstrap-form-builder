define(["view/Modal-view"], function(ModalView) {
  return describe("ModalView Generator", function() {
    beforeEach(function() {
      this.preRender = (function() {});
      this.preSave = (function() {});
      return this.view = new ModalView;
    });
    afterEach(function() {
      delete this.preRender;
      delete this.preSave;
      return this.view.remove();
    });
    it("check wrappper", function() {
      expect(this.view.$el.is(":visible")).toBeFalsy();
      expect(this.view.el.tagName).toEqual("DIV");
      return expect(this.view.$el.hasClass("modal-wrapper")).toBeTruthy();
    });
    it("check render", function() {
      var bPreRenderCall, view;

      bPreRenderCall = false;
      view = this.view;
      this.view.callback_preRender = function($el, $body) {
        var $tBody;

        bPreRenderCall = true;
        expect(arguments.length).toEqual(2);
        expect($el[0] === view.el).toBeTruthy();
        $tBody = view.$el.find(view.options.classModalBody);
        expect($tBody.length).toEqual(1);
        return expect($body[0] === $tBody[0]).toBeTruthy();
      };
      this.view.render();
      return expect(bPreRenderCall).toBeTruthy();
    });
    return it("check show", function() {
      var bPreRender, bPreSave, postSave, preRender, view;

      view = this.view;
      bPreRender = false;
      bPreSave = false;
      preRender = function($el, $body) {
        return bPreRender = true;
      };
      postSave = function($el, $body) {
        var $tBody;

        bPreSave = true;
        expect(arguments.length).toEqual(2);
        expect($el[0] === view.el).toBeTruthy();
        $tBody = view.$el.find(view.options.classModalBody);
        expect($tBody.length).toEqual(1);
        return expect($body[0] === $tBody[0]).toBeTruthy();
      };
      this.view.show({
        preRender: preRender,
        postSave: postSave
      });
      expect(bPreRender).toBeTruthy();
      view.$el.find("[data-js-save]").click();
      return expect(bPreSave).toBeTruthy();
    });
  });
});
