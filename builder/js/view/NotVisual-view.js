define(["jquery", "backbone", "underscore", "common/Log", "view/NotVisualItem-view", "sortable", "common/BackboneCustomView"], function($, Backbone, _, Log, NotVisualItem, NotVisualModel) {
  var NotVisual, log;

  log = Log.getLogger("view/NotVisual");
  NotVisual = Backbone.CustomView.extend({
    viewname: "notvisual",
    ChildType: NotVisualItem,
    templatePath: "#NotVisualViewTemplate",
    placeholderSelector: "",
    itemsSelectors: {
      loader: "[data-js-notvisual-drop]",
      loaderChildren: "[data-js-notvisual-drop] >"
    },
    initialize: function() {
      log.info("initialize " + this.cid);
      return this.listenTo(this.collection, "reset", this.on_collection_reset);
    },
    updateViewModes: function() {
      var $loader, _ref;

      log.info("updateViewModes " + this.cid);
      $loader = this.getItem("loader");
      if ((_ref = $loader.data("sortable")) != null) {
        _ref.destroy();
      }
      return $loader.sortable({
        helper: "original",
        tolerance: "pointer",
        dropOnEmpty: true,
        placeholder: "ui_notvisual__placeholder",
        start: _.bind(this.handle_sortable_start, this),
        stop: _.bind(this.handle_sortable_stop, this),
        update: _.bind(this.handle_sortable_update, this)
      });
    },
    /*
    @overwrite Backbone.CustomView
    */

    reinitialize: function() {
      var childrenCID,
        _this = this;

      log.info("reinitialize " + this.cid);
      childrenCID = _.map(this.collection.notVisualCollection.models, function(model) {
        var view;

        view = _this.getOrAddViewByModel(model);
        view.reinitialize();
        return view.cid;
      });
      return _.each(_.omit(this.childrenViews, childrenCID), function(view, cid) {
        return _this.removeChild(view);
      });
    },
    getOrAddViewByModel: function(model) {
      var filterViews, view;

      filterViews = _.filter(this.childrenViews, function(view) {
        return view.model === model;
      });
      if (filterViews.length > 0) {
        view = filterViews[0];
      } else {
        view = this.createChild({
          service: this.options.service,
          model: model,
          collection: this.collection
        });
      }
      return view;
    },
    childrenViewsOrdered: function() {
      return _.sortBy(this.childrenViews, function(view, cid) {
        return view.model.get("position");
      });
    },
    childrenConnect: function(parent, child) {
      return parent.getItem("loader").append(child.$el);
    },
    on_collection_reset: function() {
      log.info("on_collection_reset " + this.cid);
      this.reinitialize();
      return this.render();
    },
    reindex: function() {
      var _this = this;

      return _.reduce(this.getItem("loaderChildren"), (function(position, el) {
        var view, _ref;

        if ((view = Backbone.CustomView.prototype.staticViewFromEl(el))) {
          if ((_ref = view.model) != null) {
            _ref.set({
              position: position
            });
          }
          return position + 1;
        } else {
          return position;
        }
      }), 0);
    },
    handle_sortable_update: function(event, ui) {
      var componentType, data, model, view;

      log.info("handle_sortable_update " + this.cid);
      view = Backbone.CustomView.prototype.staticViewFromEl(ui.item);
      if (view != null) {
        this.reindex();
      } else {
        componentType = ui.item.data("componentType");
        data = this.options.service.getTemplateData(componentType);
        model = this.collection.addNotVisualModel(data);
        this.createChild({
          model: model,
          collection: this.collection,
          service: this.options.service
        });
      }
      return this.render();
    }
  });
  return NotVisual;
});
