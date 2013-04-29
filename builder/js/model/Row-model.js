define(["backbone"], function(Backbone) {
  var RowModel;

  RowModel = Backbone.Model.extend({
    modelname: "RowModel",
    defaults: {
      row: 0,
      fieldset: 0,
      direction: "horizontal"
    },
    validate: function(attrs, options) {
      var _ref;

      if (attrs.row < 0) {
        return "row must be >= 0";
      } else if (attrs.fieldset < 0) {
        return "fieldset must be >= 0";
      } else if ((_ref = attrs.direction) !== "horizontal" && _ref !== "vertical") {
        return "direction must be [horizontal,vertical]";
      }
    }
  });
  return RowModel;
});
