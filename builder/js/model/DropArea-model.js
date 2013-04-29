define(["backbone", "underscore"], function(Backbone, _) {
  var DropAreaModel;

  DropAreaModel = Backbone.Model.extend({
    DEFAULT_URL: "/area.json",
    HORIZONTAL: "horizontal",
    VERTICAL: "vertical",
    initialize: function(options) {
      return this.url = options.url ? options.url : this.DEFAULT_URL;
    },
    defaults: {
      direction: "horizontal",
      title: "Title",
      row: 0
    },
    validate: function(attrs, options) {
      var _ref;

      if (attrs.row < 0) {
        return "row must be >= 0";
      } else if ((_ref = attrs.direction) !== this.HORIZONTAL && _ref !== this.VERTICAL) {
        return "direction must be [horizontal,vertical]";
      } else if (attrs.title === null || attrs.title === "") {
        return "title mustn't be not null";
      }
    }
  });
  return DropAreaModel;
});
