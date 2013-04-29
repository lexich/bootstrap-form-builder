define(["backbone"], function(Backbone) {
  var FieldsetModel;

  FieldsetModel = Backbone.Model.extend({
    modelname: "FieldsetModel",
    defaults: {
      fieldset: 0,
      title: "Default title",
      direction: "horizontal"
    },
    validate: function(attrs, options) {
      var _ref;

      if (attrs.fieldset < 0) {
        return "row must be >= 0";
      } else if (attrs.title === null || attrs.title === "") {
        return "title must be not empty";
      } else if ((_ref = attrs.direction) !== "horizontal" && _ref !== "vertical") {
        return "direction must be [horizontal,vertical]";
      }
    }
  });
  return FieldsetModel;
});
