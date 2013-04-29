define(["backbone", "underscore", "common/BackboneCustomView"], function(Backbone, _) {
  return describe("BackboneCustomView", function() {
    beforeEach(function() {
      if ($("#tmplPath").length < 1) {
        $("body").append($("<script type='text/template' id='tmplPath'>"));
      }
      this.tmpl = "<div>CustomView</div>";
      $("#tmplPath").text(this.tmpl);
      return this.view = new Backbone.CustomView({
        templatePath: "#tmplPath"
      });
    });
    it("constructor", function() {
      return expect(this.view.templatePath).toEqual("#tmplPath");
    });
    it("render", function() {
      this.view.render();
      return expect(this.view.$el.html()).toEqual(this.tmpl);
    });
    it("createChild", function() {
      var childrens, view, view2;

      view = this.view.createChild();
      view2 = this.view.createChild();
      expect(view.parentView.cid).toEqual(this.view.cid);
      childrens = _.keys(this.view.childrenViews);
      expect(childrens.length).toEqual(2);
      expect([view.cid, view2.cid]).toContain(childrens[0]);
      expect([view.cid, view2.cid]).toContain(childrens[1]);
      this.view.removeChild(view2);
      expect(_.keys(this.view.childrenViews).length).toEqual(1);
      expect(view2.parentView).toEqual(null);
      expect(view.parentView.cid).toEqual(this.view.cid);
      this.view.addChild(view2);
      expect(_.keys(this.view.childrenViews).length).toEqual(2);
      expect(view2.parentView.cid).toEqual(this.view.cid);
      expect(view.parentView.cid).toEqual(this.view.cid);
      view.setParent(view2);
      expect(view.parentView.cid).toEqual(view2.cid);
      expect(_.keys(view2.childrenViews).length).toEqual(1);
      expect(_.keys(view2.childrenViews)[0]).toEqual(view.cid);
      expect(_.keys(this.view.childrenViews).length).toEqual(1);
      return expect(_.keys(this.view.childrenViews)[0]).toEqual(view2.cid);
    });
    return it("recursive render", function() {
      var bRender, bRender2, view, view2;

      view = this.view.createChild({
        templatePath: "#tmplPath"
      });
      view2 = this.view.createChild({
        templatePath: "#tmplPath"
      });
      bRender = false;
      bRender2 = false;
      view.render = function() {
        return bRender = true;
      };
      view2.render = function() {
        return bRender2 = true;
      };
      this.view.childrenConnect = function(parent, child) {
        return child.$el.appendTo(parent.$el);
      };
      this.view.render();
      expect(bRender).toBeTruthy();
      expect(bRender2).toBeTruthy();
      return expect(this.view.$el.html()).toEqual("<div>CustomView</div><div></div><div></div>");
    });
  });
});
