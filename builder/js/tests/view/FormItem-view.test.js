define(["view/FormItem-view", "model/FormItem-model"], function(FormItemView, FormItemModel) {
  return describe("FormItemView", function() {
    beforeEach(function() {
      this.model = new FormItemModel({
        direction: "horizontal",
        help: "help",
        label: "input",
        name: "input",
        placeholder: "input",
        position: 0,
        row: 0,
        size: 3,
        type: "input"
      });
      this.service = {
        getTemplate: function(type) {
          return "<div class=\"control-group\">\n<label class=\"control-label\" for=\"<%= type %>\"><%= label %></label>\n<div class=\"controls\">\n<input type=\"text\" id=\"<%= type %>\" name=\"<%= name %>\" placeholder=\"<%= placeholder %>\">\n<p class=\"help-block valtype\" data-valtype=\"help\"><%= help %></p>\n</div>\n<a data-js-close />\n<a data-js-options />\n<a data-js-inc-size />\n<a data-js-dec-size />\n</div>";
        },
        renderFormItemTemplate: function(html) {
          var templateHtml;

          templateHtml = "<%= content %>";
          return _.template(templateHtml, {
            content: html
          });
        }
      };
      this.view = new FormItemView({
        model: this.model,
        service: this.service
      });
      return this.model.trigger("change");
    });
    afterEach(function() {
      this.view.remove();
      delete this.view;
      this.model.destroy();
      delete this.model;
      return delete this.service;
    });
    it("check remove", function() {
      var bDestroy;

      bDestroy = false;
      this.model.destroy = function() {
        return bDestroy = true;
      };
      this.view.remove();
      return expect(bDestroy).toBeTruthy();
    });
    return it("check updateSize", function() {
      var size;

      size = this.model.get('size');
      expect(this.model.get("direction")).toEqual("horizontal");
      this.view.updateSize();
      expect(this.view.$el.hasClass("span" + size)).toBeFalsy();
      this.model.set("direction", "vertical", {
        silent: true
      });
      this.view.updateSize();
      return expect(this.view.$el.hasClass("span" + size)).toBeTruthy();
    });
  });
});
