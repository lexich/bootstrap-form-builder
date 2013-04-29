define(["view/Form-view", "collection/FormItem-collection"], function(FormView, FormItemCollection) {
  return describe("FormView", function() {
    var respond;

    respond = [
      {
        label: "one",
        placeholder: "two",
        type: "input1",
        name: "three",
        help: "one",
        position: "1",
        row: 2
      }, {
        label: "one",
        placeholder: "two",
        type: "input1",
        name: "three",
        help: "one",
        position: "1",
        row: 1
      }
    ];
    beforeEach(function() {
      this.server = sinon.fakeServer.create();
      this.server.respondWith("GET", "/form.json", [
        200, {
          "Content-Type": "application/json"
        }, JSON.stringify(respond)
      ]);
      this.collection = new FormItemCollection({
        url: "/form.json"
      });
      this.view = new FormView({
        collection: this.collection
      });
      return this.view.el.id = "testid";
    });
    afterEach(function() {
      this.view.remove();
      this.server.restore();
      delete this.view;
      this.collection.remove();
      return delete this.collection;
    });
    it("check initialize", function() {
      var bRender;

      bRender = false;
      this.view.render = function() {
        return bRender = true;
      };
      this.collection.fetch();
      this.server.respond();
      expect(this.collection.models.length).toEqual(2);
      return expect(bRender).toBeTruthy();
    });
    it("check renderRow", function() {
      var aRows;

      aRows = [];
      this.view.renderRow = function(row) {
        return aRows.push(row);
      };
      this.collection.fetch();
      this.server.respond();
      expect(aRows.length).toEqual(2);
      expect(aRows).toContain(0);
      expect(aRows).toContain(1);
      expect(aRows[0]).toEqual(0);
      return expect(aRows[1]).toEqual(1);
    });
    it("check getOrAddDropArea after renderRow", function() {
      var aRows, bCheckPlaceholder,
        _this = this;

      aRows = [];
      bCheckPlaceholder = true;
      this.view.getOrAddDropArea = function(row, $placeholder) {
        aRows.push(row);
        bCheckPlaceholder &= $placeholder.parents("#testid").length === 1;
        return {
          render: function() {}
        };
      };
      this.collection.fetch();
      this.server.respond();
      expect(aRows.length).toEqual(2);
      expect(aRows).toContain(0);
      expect(aRows).toContain(1);
      return expect(bCheckPlaceholder).toBeTruthy();
    });
    it("check DOM", function() {
      var $placeholder;

      this.collection.fetch();
      this.server.respond();
      $placeholder = this.view.getPlaceholder();
      expect($placeholder.parents("#testid").length).toEqual(1);
      return expect($placeholder.children().length).toEqual(2);
    });
    it("event_submitForm", function() {
      var bUpdateAll;

      this.collection.fetch();
      this.server.respond();
      bUpdateAll = false;
      this.collection.updateAll = function() {
        return bUpdateAll = true;
      };
      this.view.$el.find("[data-js-submit-form]").click();
      return expect(bUpdateAll).toBeTruthy();
    });
    it("event_addDropArea", function() {
      var max, oldMax;

      this.collection.fetch();
      this.server.respond();
      expect(_.size(this.view.dropAreas)).toEqual(2);
      oldMax = parseInt(_.chain(this.view.dropAreas).keys().max().value());
      this.view.$el.find("[data-js-add-drop-area]").click();
      max = parseInt(_.chain(this.view.dropAreas).keys().max().value());
      expect(_.size(this.view.dropAreas)).toEqual(3);
      return expect(max).toEqual(oldMax + 1);
    });
    return it("removeDropArea", function() {
      var keys, size;

      expect(this.collection.models.length).toEqual(1);
      this.collection.fetch();
      this.server.respond();
      size = _.size(this.view.dropAreas);
      expect(size).toEqual(2);
      keys = _.keys(this.view.dropAreas);
      expect(this.view.removeDropArea(keys[0])).toBeTruthy();
      return expect(_.size(this.view.dropAreas)).toEqual(size - 1);
    });
  });
});
