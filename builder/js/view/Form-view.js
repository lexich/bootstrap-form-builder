define(["jquery", "backbone", "underscore", "view/Fieldset-view", "model/Fieldset-model", "common/Log", "common/BackboneCustomView", "droppable"], function($, Backbone, _, FieldsetView, FieldsetModel, Log) {
  var FormView, log;

  log = Log.getLogger("view/FormView");
  FormView = Backbone.CustomView.extend({
    /*
    Variables Backbone.View
    */

    className: "ui_formview",
    /*
    Variables Backbone.CustomView
    */

    viewname: "form",
    ChildType: FieldsetView,
    templatePath: "#FormViewTemplate",
    itemsSelectors: {
      loader: "[data-html-formloader]:first",
      fieldsets: "form  fieldset"
    },
    /*
    @overwrite Backbone.View
    */

    initialize: function() {
      log.info("initialize " + this.cid);
      return this.collection.on("reset", _.bind(this.on_collection_reset, this));
    },
    remove: function() {
      var _ref, _ref1,
        _this = this;

      if ((_ref = this.parentView) != null) {
        _ref.removeChild(this);
      }
      if ((_ref1 = this.parentView) != null) {
        _ref1.updateViewModes();
      }
      return _.each(this.childrenViews, function(view, k) {
        _this.removeChild(view);
        return view.remove();
      });
    },
    /*
    bind to event 'reset' for current collection
    */

    on_collection_reset: function() {
      log.info("on_collection_reset " + this.cid);
      this.reinitialize();
      return this.render();
    },
    /*
    @overwrite Backbone.CustomView
    */

    reindex: function() {
      var _this = this;

      log.info("reindex " + this.cid);
      return _.reduce(this.getItem("fieldsets"), (function(fieldset, el) {
        var view, _ref;

        if ((view = Backbone.CustomView.prototype.staticViewFromEl(el))) {
          if ((_ref = view.model) != null) {
            _ref.set({
              fieldset: fieldset
            }, {
              validate: true
            });
          }
          return fieldset + 1;
        }
      }), 0);
    },
    /*
    @overwrite Backbone.CustomView
    */

    reinitialize: function() {
      var childrenCID,
        _this = this;

      log.info("reinitialize " + this.cid);
      childrenCID = _.chain(this.collection.models).groupBy(function(model) {
        return model.get("fieldset");
      }).map(function(models, fieldset) {
        var view;

        fieldset = toInt(fieldset);
        view = _this.getOrAddFieldsetView(fieldset);
        if (typeof view.reinitialize === "function") {
          view.reinitialize();
        }
        return view.cid;
      }).value();
      return _.each(_.omit(this.childrenViews, childrenCID), function(view, cid) {
        return _this.removeChild(view);
      });
    },
    /*
    @overwrite Backbone.CustomView
    */

    childrenConnect: function(self, view) {
      var $loader;

      log.info("childrenConnect " + this.cid);
      $loader = self.getItem("loader");
      return $loader.append(view.$el);
    },
    /*
    Find view by fieldset index or add New
    */

    getOrAddFieldsetView: function(fieldset) {
      var filterViews, view;

      filterViews = _.filter(this.childrenViews, function(view) {
        return view.model.get("fieldset") === fieldset;
      });
      if (filterViews.length > 0) {
        view = filterViews[0];
      } else {
        view = this.createChild({
          service: this.options.service,
          model: this.collection.getOrAddFieldsetModel(fieldset),
          collection: this.collection,
          accept: function($el) {
            return $el.hasClass("ui-draggable");
          }
        });
      }
      return view;
    },
    /*
    @overwrite Backbone.CustomView
    */

    handle_create_new: function(event, ui) {
      var fieldset, view;

      log.info("handle_create_new");
      view = Backbone.CustomView.prototype.staticViewFromEl(ui.item);
      fieldset = _.size(this.childrenViews);
      if ((view != null) && view.viewname === "fieldset") {
        this.addChild(view);
        view.model.set("fieldset", fieldset, {
          validate: true
        });
      } else {
        view = this.getOrAddFieldsetView(fieldset);
        view.handle_create_new(event, ui).reindex();
      }
      return this;
    }
  });
  return FormView;
});
