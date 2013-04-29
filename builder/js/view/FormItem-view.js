define(["jquery", "backbone", "underscore", "common/Log", "common/BackboneCustomView", "common/BackboneWireMixin"], function($, Backbone, _, Log) {
  var CustomView, FormItemView, log;

  log = Log.getLogger("view/FormItemView");
  CustomView = (function(log, __super__) {
    return __super__.extend({
      templatePath: "#FormItemViewTemplate",
      viewname: "formitem",
      itemsSelectors: {
        controls: ".controls",
        input: "input,select,textarea",
        moveElement: ".ui_formitem__move"
      },
      updateViewModes: function() {
        var $item, $move, bVertical, size;

        __super__.prototype.updateViewModes.apply(this, arguments);
        bVertical = this.model.get("direction") === "vertical";
        size = this.model.get("size");
        if (!bVertical && size > this.HORIZONTAL_SIZE_LIMIT) {
          this.model.set("size", this.HORIZONTAL_SIZE_LIMIT, {
            validate: true,
            silent: true
          });
          size = this.model.get("size");
        }
        $item = this.getItem("input");
        this.cleanSpan(this.$el);
        this.cleanSpan($item);
        if (bVertical) {
          this.$el.addClass("span" + size);
          $item.addClass("span12");
        } else {
          $item.addClass("span" + (this.model.get('size')));
        }
        $move = this.getItem("moveElement");
        if (this.model.get("direction") === "vertical") {
          return $move.removeAttr("data-js-row-move").attr("data-js-formitem-move", "");
        } else {
          return $move.removeAttr("data-js-formitem-move").attr("data-js-row-move", "");
        }
      },
      templateData: function() {
        var content, data, templateHtml;

        templateHtml = this.options.service.getTemplate(this.model.get("type"));
        data = _.extend({
          id: _.uniqueId("tmpl_")
        }, this.model.attributes);
        content = _.template(templateHtml, data);
        return {
          content: content,
          model: this.model.attributes,
          cid: this.cid
        };
      }
    });
  })(log, Backbone.CustomView);
  FormItemView = (function(__super__) {
    return __super__.extend({
      SELECTED_CLASS: "ui_formitem__editablemode",
      HORIZONTAL_SIZE_LIMIT: 12,
      className: "ui_formitem",
      events: {
        "click [data-js-formitem-decsize]": "event_decsize",
        "click [data-js-formitem-incsize]": "event_incsize",
        "click [data-js-formitem-remove]": "event_remove",
        "click": "event_clickEditable"
      },
      wireEvents: {
        "editableView:change": "on_editableView_change",
        "editableView:remove": "on_editableView_remove"
      },
      initialize: function() {
        log.info("initialize " + this.cid);
        this.$el.data(DATA_VIEW, this);
        return this.listenTo(this.model, "change", this.on_model_change);
      },
      remove: function() {
        log.info("remove " + this.cid);
        this.unbindWireEvents();
        return __super__.prototype.remove.apply(this, arguments);
      },
      /*
      handler receive after change this.model
      */

      on_model_change: function() {
        log.info("on_model_change " + this.cid);
        return this.render();
      },
      /*
      editable view change, this view ,must be disconnected
      @param view - new view
      */

      on_editableView_change: function(view) {
        var _ref;

        log.info("on_editableView_change " + this.cid);
        if (view === this) {
          return;
        }
        this.unbindWireEvents();
        this.$el.removeClass(this.SELECTED_CLASS);
        return (_ref = this.parentView) != null ? typeof _ref.setSelected === "function" ? _ref.setSelected(false) : void 0 : void 0;
      },
      /*
      editableView must be remove
      */

      on_editableView_remove: function() {
        log.info("on_editableView_remove " + this.cid);
        return this.remove();
      },
      /*
      Decrement control size
      */

      event_decsize: function() {
        var size;

        log.info("event_decsize " + this.cid);
        size = this.model.get("size");
        if (size > 2) {
          return this.model.set("size", size - 1, {
            validate: true
          });
        }
      },
      /*
      Increment control size
      */

      event_incsize: function() {
        var rowSize, size;

        log.info("event_incsize " + this.cid);
        rowSize = this.parentView.getCurrentRowSize();
        size = this.model.get("size");
        if (this.model.get("direction") === "horizontal" && rowSize > this.HORIZONTAL_SIZE_LIMIT) {
          return;
        }
        if (rowSize < 12) {
          return this.model.set("size", size + 1, {
            validate: true
          });
        }
      },
      /*
      Remove current item
      */

      event_remove: function() {
        log.info("event_remove " + this.cid);
        return this.remove();
      },
      /*
      set Editable mode to current view
      @param e - {Event}
      */

      event_clickEditable: function(e) {
        var _ref;

        log.info("event_clickEditable " + this.cid);
        if ($(e.target).hasClass("ui_formitem__tools") || $(e.target).parents(".ui_formitem__tools").length > 0) {
          return;
        }
        if (this.options.service.setEditableView(this)) {
          this.bindWireEvents(this.options.service, this.wireEvents);
          this.$el.addClass(this.SELECTED_CLASS);
          return (_ref = this.parentView) != null ? typeof _ref.setSelected === "function" ? _ref.setSelected(true) : void 0 : void 0;
        }
      }
    });
  })(CustomView.extend(Backbone.WireMixin, log = log));
  return FormItemView;
});
