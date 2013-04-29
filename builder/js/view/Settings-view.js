define(["jquery", "backbone", "underscore", "common/Log", "spinner", "select2"], function($, Backbone, _, Log) {
  var SettingsView, log;

  log = Log.getLogger("view/SettingsView");
  SettingsView = Backbone.View.extend({
    visibleMode: false,
    activeView: null,
    events: {
      "click [data-html-settings-item] [data-js-save]": "event_itemSave",
      "click [data-html-settings-item] [data-js-remove]": "event_itemRemove",
      "click [data-html-settings-item] [data-js-hide]": "event_itemHide"
    },
    initialize: function() {
      var _this = this;

      log.info("initialize");
      this.$el.addClass("hide");
      _.bindAll(this);
      this.listenTo(this.options.service, "editableView:set", this.on_editableView_set);
      return this.modalTemplates = _.reduce($("[data-" + this.options.dataPostfixModalType + "]"), (function(memo, item) {
        var type;

        type = $(item).data(_this.options.dataPostfixModalType);
        if ((type != null) && type !== "") {
          memo[type] = $(item).html();
        }
        return memo;
      }), {});
    },
    getArea: function() {
      return $("[data-html-settings-loader]", this.$el);
    },
    setVisibleMode: function(bValue) {
      var $item,
        _this = this;

      log.info("setVisibleMode " + bValue);
      this.visibleMode = bValue;
      $item = $("[data-html-settings]");
      $(document).off("mousedown", this.handle_VisibleMode);
      if (bValue) {
        $item.removeClass("hide");
        return setTimeout((function() {
          return $(document).on("mousedown", _this.handle_VisibleMode);
        }), 0);
      } else {
        $item.addClass("hide");
        $(".select2-drop").hide();
        return this.options.service.trigger("editableView:change");
      }
    },
    handle_VisibleMode: function(e) {
      log.info("handle_VisibleMode");
      if (this.__find(this.$el, e.target)) {
        return;
      }
      if ((this.activeView != null) && this.__find(this.activeView.$el, e.target)) {
        return;
      }
      return this.setVisibleMode(false);
    },
    ui: {
      select2: function($el, options) {
        var bSelected, opts, val;

        options = options != null ? options : {};
        options.closeOnSelect = true;
        val = $el.data("value");
        if ($el[0].tagName.toLowerCase() === "select" && (options.data != null)) {
          bSelected = false;
          opts = _.map(options.data || [], function(item) {
            var selected;

            if (item.id === val) {
              bSelected = true;
              selected = "selected";
            } else {
              selected = "";
            }
            return "<option " + selected + " value='" + item.id + "'>" + item.text + "</option>";
          });
          if (!bSelected) {
            opts.splice(0, 0, "<option></option>");
          }
          $el.html(opts.join(""));
          delete options.data;
        }
        return $el.select2(options);
      },
      spinner: function($el, options) {
        return $el.spinner(options != null ? options : {});
      }
    },
    render: function() {
      var $body, data, model, type, _ref,
        _this = this;

      log.info("render");
      if (!(model = (_ref = this.activeView) != null ? _ref.model : void 0)) {
        return;
      }
      $body = this.getArea();
      type = model.get("type");
      data = model.attributes;
      $body.empty();
      $body.append(this.renderForm(type, data));
      return _.each($body.find("[data-ui]"), function(el) {
        var uicomponent;

        uicomponent = $(el).data("ui");
        if (_this.ui[uicomponent] != null) {
          data = $(el).data("ui-data");
          if ((data != null ? data.inject : void 0) != null) {
            _.each(data.inject, function(v, k) {
              return data[k] = _.result(_this, v);
            });
            delete data.inject;
          }
          return _this.ui[uicomponent]($(el), data);
        }
      });
    },
    loadIds: function() {
      return _.map(this.collection.models, function(model) {
        return {
          id: model.get("id"),
          text: model.get("name") + ("#" + (model.get("id")))
        };
      });
    },
    renderForm: function(type, data) {
      var $frag, $item, content, meta,
        _this = this;

      log.info("renderForm");
      $frag = $("<div>");
      $item = $("[data-ui-jsrender-modal-template='" + type + "']:first");
      if ($item.length === 1) {
        $frag.html($item.html());
        _.each($("input,select,textarea", $frag), function(input) {
          var $input, value;

          $input = $(input);
          type = $input.attr("name");
          value = data[type];
          if (!_.isUndefined(value)) {
            return $input.val(value).data("value", value);
          }
        });
      } else {
        meta = this.options.service.getTemplateMetaData(type);
        content = _.map(data, function(v, k) {
          var itemType, opts, tmpl, _ref;

          itemType = (_ref = meta[k]) != null ? _ref : "hidden";
          opts = {
            name: k,
            value: v,
            data: _this.options.service.getItemFormTypes()
          };
          tmpl = _this.renderModalItemTemplate(itemType, opts);
          return tmpl;
        });
        $frag.html(content.join(""));
      }
      return $frag.children();
    },
    renderModalItemTemplate: function(type, data) {
      var templateHtml;

      log.info("renderModalItemTemplate");
      if (type === null || type === "") {
        type = "input";
      }
      templateHtml = this.modalTemplates[type];
      if ((templateHtml != null) && templateHtml !== "") {
        return _.template(templateHtml, data);
      } else {
        return "";
      }
    },
    on_editableView_set: function(view) {
      log.info("on_editableView_set");
      this.activeView = view;
      if (view != null) {
        this.render();
        return this.setVisibleMode(true);
      }
    },
    event_itemSave: function() {
      var data, model, service, _ref;

      log.info("event_itemSave");
      service = this.options.service;
      if (!(model = (_ref = this.activeView) != null ? _ref.model : void 0)) {
        return;
      }
      data = service.parceModalItemData(this.getArea());
      model.set(data, {
        validate: true
      });
      if (!model.isValid()) {
        return log.error(model.validationError);
      }
    },
    event_itemRemove: function() {
      log.info("event_itemRemove");
      this.options.service.trigger("editableView:remove");
      return this.setVisibleMode(false);
    },
    event_itemHide: function() {
      log.info("event_itemHide");
      return this.setVisibleMode(false);
    },
    __find: function($el, target) {
      log.info("__find");
      if ($el == null) {
        return false;
      }
      if ($el[0] === target) {
        return true;
      } else {
        if ($el.find($(target)).length > 0) {
          return true;
        }
      }
      return false;
    }
  });
  return SettingsView;
});
