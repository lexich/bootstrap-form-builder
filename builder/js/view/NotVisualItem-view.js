define(["jquery", "backbone", "underscore", "common/Log", "sortable", "common/BackboneCustomView", "common/BackboneWireMixin"], function($, Backbone, _, Log) {
  var CustomView, NotVisualItem, log;

  log = Log.getLogger("view/NotVisualItem");
  CustomView = (function(__super__, log) {
    return __super__.extend({
      viewname: "notvisualitem",
      templatePath: "#NotVisualItemTemplate",
      templateData: function() {
        var content, data, templateHTML;

        templateHTML = this.options.service.getTemplate(this.model.get("type"));
        data = _.extend({
          id: _.uniqueId("notvisual_")
        }, this.model.attributes);
        content = _.template(templateHTML, data);
        return {
          content: content,
          model: this.model.attributes,
          cid: this.cid
        };
      },
      itemsSelectors: {
        loader: "[data-js-notvisual-drop]"
      }
    });
  })(Backbone.CustomView, log);
  NotVisualItem = (function(__super__) {
    return __super__.extend({
      SELECTED_CLASS: "ui_notvisual__item-active",
      className: "ui_notvisual__item",
      wireEvents: {
        "editableView:change": "on_editableView_change",
        "editableView:remove": "on_editableView_remove"
      },
      events: {
        "click": "event_clickEditable"
      },
      initialize: function() {
        log.info("initialize " + this.cid);
        return this.listenTo(this.model, "change", this.on_model_change);
      },
      remove: function() {
        log.info("remove " + this.cid);
        this.unbindWireEvents();
        return __super__.prototype.remove.apply(this, arguments);
      },
      event_clickEditable: function() {
        log.info("event_clickEditable " + this.cid);
        if (this.options.service.setEditableView(this)) {
          this.bindWireEvents(this.options.service, this.wireEvents);
          return this.$el.addClass(this.SELECTED_CLASS);
        }
      },
      on_model_change: function() {
        log.info("on_model_change " + this.cid);
        return this.render();
      },
      on_editableView_change: function(view) {
        log.info("on_editableView_change " + this.cid);
        if (view === this) {
          return;
        }
        this.unbindWireEvents();
        return this.$el.removeClass(this.SELECTED_CLASS);
      },
      on_editableView_remove: function() {
        log.info("on_editableView_remove " + this.cid);
        return this.remove();
      }
    });
  })(CustomView.extend(Backbone.WireMixin, log = log));
  return NotVisualItem;
});
