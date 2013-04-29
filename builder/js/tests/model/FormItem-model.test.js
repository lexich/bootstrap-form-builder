define(["model/FormItem-model"], function(FormItemModel) {
  return describe("FormItemModel", function() {
    beforeEach(function() {
      return this.model = new FormItemModel;
    });
    it("default init", function() {
      expect(this.model.get("position")).toEqual(0);
      expect(this.model.get("row")).toEqual(0);
      expect(this.model.get("label")).toEqual("");
      expect(this.model.get("placeholder")).toEqual("");
      expect(this.model.get("type")).toEqual("input");
      expect(this.model.get("name")).toEqual("");
      expect(this.model.get("help")).toEqual("");
      expect(this.model.get("direction")).toEqual("horizontal");
      return expect(this.model.get("size")).toEqual(3);
    });
    it("initialization", function() {
      this.model.set({
        label: "test1",
        placeholder: "test2",
        type: "test3",
        name: "test4",
        help: "test5",
        position: 1,
        row: 2,
        direction: "vertical"
      }, {
        validate: true
      });
      expect(this.model.validationError).toBeNull();
      expect(this.model.get("position")).toEqual(1);
      expect(this.model.get("row")).toEqual(2);
      expect(this.model.get("label")).toEqual("test1");
      expect(this.model.get("placeholder")).toEqual("test2");
      expect(this.model.get("type")).toEqual("test3");
      expect(this.model.get("name")).toEqual("test4");
      expect(this.model.get("help")).toEqual("test5");
      return expect(this.model.get("direction")).toEqual("vertical");
    });
    return it("validate", function() {
      var error;

      this.model.set({
        label: "test1",
        placeholder: "test2",
        type: "test3",
        name: "test4",
        help: "test5",
        position: 1,
        row: 2,
        direction: "vertical"
      });
      expect(this.model.validationError).not.toBeDefined();
      error = this.model.validationError;
      this.model.set({
        label: ""
      }, {
        validate: true
      });
      expect(this.model.validationError).toBeDefined();
      expect(this.model.validationError.length).toBeGreaterThan(1);
      error = this.model.validationError;
      this.model.set({
        label: null
      }, {
        validate: true
      });
      expect(this.model.validationError).toEqual(error);
      error = this.model.validationError;
      this.model.set({
        placeholder: ""
      }, {
        validate: true
      });
      expect(this.model.validationError).not.toEqual(error);
      error = this.model.validationError;
      this.model.set({
        placeholder: null
      }, {
        validate: true
      });
      expect(this.model.validationError).toEqual(error);
      error = this.model.validationError;
      this.model.set({
        type: ""
      }, {
        validate: true
      });
      expect(this.model.validationError).not.toEqual(error);
      error = this.model.validationError;
      this.model.set({
        type: null
      }, {
        validate: true
      });
      expect(this.model.validationError).toEqual(error);
      error = this.model.validationError;
      this.model.set({
        name: ""
      }, {
        validate: true
      });
      expect(this.model.validationError).not.toEqual(error);
      error = this.model.validationError;
      this.model.set({
        name: null
      }, {
        validate: true
      });
      expect(this.model.validationError).toEqual(error);
      error = this.model.validationError;
      this.model.set({
        help: ""
      }, {
        validate: true
      });
      expect(this.model.validationError).toBeNull();
      error = this.model.validationError;
      this.model.set({
        help: null
      }, {
        validate: true
      });
      expect(this.model.validationError).not.toEqual(error);
      error = this.model.validationError;
      this.model.set({
        position: ""
      }, {
        validate: true
      });
      expect(this.model.validationError).not.toEqual(error);
      error = this.model.validationError;
      this.model.set({
        position: null
      }, {
        validate: true
      });
      expect(this.model.validationError).toEqual(error);
      error = this.model.validationError;
      this.model.set({
        position: -1
      }, {
        validate: true
      });
      expect(this.model.validationError).not.toBeNull();
      error = this.model.validationError;
      this.model.set({
        position: 0
      }, {
        validate: true
      });
      expect(this.model.validationError).toBeNull();
      error = this.model.validationError;
      this.model.set({
        row: ""
      }, {
        validate: true
      });
      expect(this.model.validationError).not.toEqual(error);
      error = this.model.validationError;
      this.model.set({
        row: null
      }, {
        validate: true
      });
      expect(this.model.validationError).toEqual(error);
      error = this.model.validationError;
      this.model.set({
        row: -1
      }, {
        validate: true
      });
      expect(this.model.validationError).not.toBeNull();
      error = this.model.validationError;
      this.model.set({
        row: 0
      }, {
        validate: true
      });
      expect(this.model.validationError).toBeNull();
      error = this.model.validationError;
      this.model.set({
        direction: ""
      }, {
        validate: true
      });
      expect(this.model.validationError).not.toBeNull();
      error = this.model.validationError;
      this.model.set({
        name: "vertical"
      }, {
        validate: true
      });
      expect(this.model.validationError).toBeNull();
      this.model.set({
        name: "horizontal"
      }, {
        validate: true
      });
      expect(this.model.validationError).toBeNull();
      expect(this.model.set({
        size: 0
      }, {
        validate: true
      })).toBeFalsy();
      expect(this.model.set({
        size: 13
      }, {
        validate: true
      })).toBeFalsy();
      return expect(this.model.set({
        size: 1
      }, {
        validate: true
      })).toBeTruthy();
    });
  });
});
