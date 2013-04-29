define(["model/FormItem-model", "collection/FormItem-collection"], function(FormItemModel, FormItemCollection) {
  var respond;

  respond = [
    {
      label: "one",
      placeholder: "two",
      type: "input1",
      name: "three",
      help: "one",
      position: "2",
      row: 2,
      direction: "horizontal"
    }, {
      label: "one",
      placeholder: "two",
      type: "input1",
      name: "three",
      help: "one",
      position: "1",
      row: 1,
      direction: "vertical"
    }, {
      label: "one",
      placeholder: "two",
      type: "input1",
      name: "three",
      help: "one",
      position: "1",
      row: 1,
      direction: "horizontal"
    }
  ];
  return describe("Test collection", function() {
    beforeEach(function() {
      this.server = sinon.fakeServer.create();
      this.server.respondWith("GET", "/forms1.json", [
        200, {
          "Content-Type": "application/json"
        }, JSON.stringify(respond)
      ]);
      return this.collection = new FormItemCollection({
        url: "/forms1.json"
      });
    });
    afterEach(function() {
      this.server.restore();
      return delete this.collection;
    });
    it("initialize", function() {
      return expect(this.collection.models.length).toEqual(1);
    });
    it("fetch data", function() {
      var model;

      this.collection.fetch();
      this.server.respond();
      expect(this.collection.models.length).toEqual(3);
      model = this.collection.models[0];
      expect(model.get("label")).toEqual("one");
      expect(model.get("placeholder")).toEqual("two");
      expect(model.get("type")).toEqual("input1");
      expect(model.get("name")).toEqual("three");
      expect(model.get("help")).toEqual("one");
      expect(model.get("position")).toEqual(1);
      return expect(model.get("row")).toEqual(0);
    });
    it("Collection updateAll", function() {
      var model, request;

      sinon.spy();
      model = new FormItemModel({
        label: "one",
        placeholder: "two",
        type: "input1",
        name: "three",
        help: "one",
        position: "1",
        row: 2
      });
      this.collection.push(model);
      this.collection.updateAll();
      expect(this.server.requests.length).toEqual(1);
      request = this.server.requests[0];
      expect(request.method).toEqual("POST");
      expect(request.url).toEqual("/forms1.json");
      return expect(request.requestBody).toEqual(JSON.stringify(this.collection.toJSON()));
    });
    it("Collection parce", function() {
      var resp;

      expect(respond.length).toEqual(3);
      expect(respond[0].row).toEqual(2);
      expect(respond[1].row).toEqual(1);
      expect(respond[1].row).toEqual(1);
      resp = this.collection.parse(respond);
      expect(resp[0].row).toEqual(0);
      expect(resp[1].row).toEqual(0);
      return expect(resp[2].row).toEqual(1);
    });
    return it("Collection smartSliceNormalize", function() {
      var models, row;

      this.collection.fetch();
      this.server.respond();
      expect(this.collection.models.length).toEqual(3);
      row = 0;
      models = this.collection.where({
        row: row
      });
      expect(models.length).toEqual(2);
      expect(models[0].get("direction")).toEqual("vertical");
      expect(models[1].get("direction")).toEqual("horizontal");
      models = this.collection.smartSliceNormalize(row, "direction", "vertical");
      expect(models.length).toEqual(2);
      expect(models[0].get("direction")).toEqual("vertical");
      expect(models[1].get("direction")).toEqual("vertical");
      this.collection.smartSliceNormalize(row, "direction", "horizontal");
      expect(models[0].get("direction")).toEqual("vertical");
      return expect(models[1].get("direction")).toEqual("vertical");
    });
  });
});
