var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(["backbone", "underscore", "common/Log"], function(Backbone, _, Log) {
  var FormItemModel, log;

  log = Log.getLogger("model/FormItemModel");
  FormItemModel = Backbone.Model.extend({
    modelname: "FormItemModel",
    defaults: {
      label: "",
      placeholder: "",
      type: "input",
      name: "",
      help: "",
      direction: "horizontal",
      position: 0,
      row: 0,
      fieldset: 0,
      size: 3
    },
    initialize: function() {
      return log.info("initialize");
    },
    parse: function(attrs, options) {
      var intParams, result;

      log.info("parse");
      intParams = _.reduce(this.defaults, (function(memo, v, k) {
        if (isPositiveInt(v)) {
          memo.push(k);
        }
        return memo;
      }), []);
      result = _.reduce(attrs, (function(memo, v, k) {
        if (__indexOf.call(intParams, k) >= 0) {
          memo[k] = toInt(v);
        } else {
          memo[k] = v;
        }
        return memo;
      }), {});
      return result;
    },
    validate: function(attrs, options) {
      var _ref;

      if (attrs.label === null || attrs.label === "") {
        return "label mustn't be not null";
      } else if (attrs.placeholder === null || attrs.placeholder === "") {
        return "placeholder mustn't be not null";
      } else if (attrs.type === null || attrs.type === "") {
        return "type mustn't be not null";
      } else if (attrs.help === null) {
        return "help mustn't be null";
      } else if (!_.isNumber(attrs.row)) {
        return "row must be integer";
      } else if ((_ref = attrs.direction) !== "horizontal" && _ref !== "vertical") {
        return "direction must be [horizontal,vertical]";
      } else if (attrs.row < 0) {
        return "row must be >= 0";
      } else if (!_.isNumber(attrs.position)) {
        return "position must be integer";
      } else if (attrs.position < 0) {
        return "position must be >= 0";
      } else if (attrs.fieldset < 0) {
        return "fieldset must be >= 0";
      } else if (!_.isNumber(attrs.size)) {
        return "size must be number";
      } else if (attrs.size < 1 || attrs.size > 12) {
        return "size must be more then 0 and less or equal then 12";
      }
    }
  });
  return FormItemModel;
});
