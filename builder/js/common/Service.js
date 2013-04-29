define(["jquery", "backbone", "underscore", "view/FormItem-view", "common/Log"], function($, Backbone, _, FormItemView, Log) {
  var Service, log;

  log = Log.getLogger("common/Service");
  Service = function() {
    this.initialize.apply(this, arguments);
    return this;
  };
  _.extend(Service.prototype, Backbone.Events, {
    constructor: Service,
    toolData: {},
    editableView: null,
    /*
    --OPTIONS--
    @param dataToolBinder
    
    @param dataPostfixModalType - data-* postfix for search modal-items templates
    @param modal -
    */

    initialize: function(options) {
      this.toolData = this.getToolData(options.dataToolBinder);
      return this.listenTo(this, "editableView:change", this.on_editableView_change);
    },
    getData: function(type) {
      return this.toolData[type];
    },
    getItemFormTypes: function() {
      return _.keys(this.toolData);
    },
    getTemplateMetaData: function(type) {
      var _ref;

      return (_ref = this.getData(type)) != null ? _ref.meta : void 0;
    },
    getTemplateData: function(type) {
      var data, _ref, _ref1;

      data = (_ref = (_ref1 = this.getData(type)) != null ? _ref1.data : void 0) != null ? _ref : {};
      data.id = _.uniqueId(type);
      return data;
    },
    getTemplate: function(type) {
      var _ref;

      return (_ref = this.getData(type)) != null ? _ref.template : void 0;
    },
    parceModalItemData: function($body) {
      var pattern,
        _this = this;

      log.info("parceModalItemData");
      pattern = "input[name], select[name]";
      return _.reduce($body.find(pattern), (function(memo, item) {
        var name;

        name = $(item).attr("name");
        if ((name != null) && name !== "") {
          memo[name] = _this.convertData($(item).val(), $(item).data("type"));
        }
        return memo;
      }), {});
    },
    convertData: function(val, type) {
      log.info("convertData");
      if (type === 'int') {
        return parseInt(val);
      } else if (type === 'float') {
        return parseFloat(val);
      } else {
        return val;
      }
    },
    getToolData: function(toolBinder) {
      var _this = this;

      log.info("getToolData");
      return _.reduce($("*[data-" + toolBinder + "]"), (function(memo, el) {
        var $el, data, meta, type, _ref;

        $el = $(el);
        type = $el.data(toolBinder + "-type");
        _ref = [{}, {}], data = _ref[0], meta = _ref[1];
        _.each($el.data(toolBinder), function(v, k) {
          if (_.isString(v)) {
            data[k] = v;
            return meta[k] = "";
          } else if (_.isObject(v)) {
            data[k] = v.value != null ? v.value : "";
            return meta[k] = v.type != null ? v.type : "";
          }
        });
        memo[type] = {
          type: type,
          data: data,
          meta: meta,
          title: data.title,
          img: $el.data(toolBinder + "-img"),
          template: $el.html(),
          $el: $el
        };
        return memo;
      }), {});
    },
    on_editableView_change: function(view) {
      log.info("on_editableView_change");
      this.editableView = view;
      return this.trigger("editableView:set", view);
    },
    setEditableView: function(view) {
      log.info("setEditableView");
      if (this.editableView !== view) {
        this.trigger("editableView:change", view);
        return true;
      } else {
        return false;
      }
    },
    getEditableModel: function() {
      var _ref;

      log.error("getEditableModel");
      return (_ref = this.editableView) != null ? _ref.model : void 0;
    }
  });
  return Service;
});
