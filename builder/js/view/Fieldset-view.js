define(["jquery", "backbone", "underscore", "view/Row-view", "model/Row-model", "common/Log", "common/BackboneCustomView", "sortable"], function($, Backbone, _, RowView, RowModel, Log) {
  /*
  CustomView
  */

  var CustomView, FieldsetView, UIView;

  CustomView = (function(__super__, log) {
    return __super__.extend({
      viewname: "fieldset",
      ChildType: RowView,
      templatePath: "#FieldsetViewTemplate",
      placeholderSelector: "[data-drop-accept-placeholder='form']",
      itemsSelectors: {
        loader: "[data-html-fieldset-loader]",
        loaderChildren: "[data-html-fieldset-loader] >",
        direction: "[data-js-fieldset-position]"
      },
      updateViewModes: function() {
        var connector, sortable;

        log.info("updateViewModes " + this.cid);
        if ((sortable = this.getItem("loader").data("sortable"))) {
          sortable.destroy();
        }
        __super__.prototype.updateViewModes.apply(this, arguments);
        connector = "[data-html-fieldset-loader]:not([data-js-row-disable-drag]),[data-drop-accept-placeholder='form']";
        this.getItem("loader").sortable({
          helper: "original",
          handle: "[data-js-row-move]",
          tolerance: "pointer",
          dropOnEmpty: true,
          placeholder: "ui_row__placeholder",
          connectWith: connector,
          start: _.bind(this.handle_sortable_start, this),
          stop: _.bind(this.handle_sortable_stop, this),
          update: _.bind(this.handle_sortable_update, this)
        });
        if (this.model.get("direction") === "vertical") {
          this.getItem("direction").addClass("icon-resize-horizontal").removeClass("icon-resize-vertical");
          this.$el.find(".ui_global_placeholder").not('.ui_row__prev_loader').removeClass("form-horizontal");
        } else {
          this.getItem("direction").addClass("icon-resize-vertical").removeClass("icon-resize-horizontal");
          this.$el.find(".ui_global_placeholder").not('.ui_row__prev_loader').addClass("form-horizontal");
        }
        this.updateDirectionVisible();
        return this;
      },
      childrenConnect: function(self, view) {
        return self.getItem("loader").append(view.$el);
      },
      reindex: function() {
        var _this = this;

        log.info("reindex " + this.cid);
        return _.reduce(this.getItem("loaderChildren"), (function(row, el) {
          var view, _ref;

          if ((view = __super__.prototype.staticViewFromEl(el))) {
            if ((_ref = view.model) != null) {
              _ref.set({
                row: row,
                fieldset: _this.model.get("fieldset"),
                direction: _this.model.get("direction", {
                  validate: true
                })
              });
            }
          }
          return row + 1;
        }), 0);
      },
      handle_create_new: function(event, ui) {
        var row, view;

        log.info("handle_create_new " + this.cid);
        view = __super__.prototype.staticViewFromEl(ui.item);
        row = _.size(this.childrenViews);
        if ((view != null) && view.viewname === "row") {
          this.addChild(view);
          view.model.set({
            fieldset: this.model.get("fieldset"),
            row: row
          }, {
            validate: true
          });
        } else {
          view = this.getOrAddRowView(row);
          view.handle_create_new(event, ui).reindex();
        }
        return this;
      },
      childrenViewsOrdered: function() {
        return _.sortBy(this.childrenViews, function(view, cid) {
          return view.model.get("row");
        });
      },
      reinitialize: function() {
        var childrenCID, fieldset, rows,
          _this = this;

        log.info("reinitialize " + this.cid);
        fieldset = this.model.get("fieldset");
        rows = _.keys(this.collection.getFieldsetGroupByRow(fieldset));
        childrenCID = _.map(rows, function(row) {
          var view;

          row = toInt(row);
          view = _this.getOrAddRowView(row);
          view.reinitialize();
          return view.cid;
        });
        return _.chain(this.childrenViews).omit(childrenCID).each(function(view, cid) {
          return _this.removeChild(view);
        });
      }
    });
  })(Backbone.CustomView, Log.getLogger("view/FieldsetView_CustomView"));
  /*
  UIView
  */

  UIView = (function(__super__, log) {
    return __super__.extend({
      handle_sortable_update: function(event, ui) {
        var parentView, rowView;

        log.info("handle_sortable_update " + this.cid);
        rowView = __super__.prototype.staticViewFromEl(ui.item);
        if (ui.sender != null) {
          log.info("handle_sortable_update " + this.cid + " ui.sender != null");
          if (rowView) {
            parentView = rowView.parentView;
            if (parentView !== this) {
              rowView.setParent(this);
              return this.reindex();
            }
          } else {
            return rowView = this.createChild({
              el: ui.helper,
              model: new RowModel({
                fieldset: this.model.get("fieldset"),
                direction: this.model.get("direction")
              }),
              service: this.options.service
            });
          }
        }
      }
    });
  })(CustomView, Log.getLogger("view/FieldsetView_UIView"));
  /*
  FieldsetView
  */

  FieldsetView = (function(__super__, log) {
    return __super__.extend({
      /*
      Variables Backbone.View
      */

      tagName: "fieldset",
      className: "ui_fieldset",
      events: {
        "click [data-js-remove-fieldset]": "event_clickRemove",
        "input [contenteditable][data-bind]": "event_inputDataBind",
        "click [data-js-fieldset-position]": "event_clickDirection"
      },
      initialize: function() {
        log.info("initialize " + this.cid);
        return this.model.on("change", _.bind(this.on_model_change, this));
      },
      insertRow: function(row) {
        var filterRowView;

        log.info("insertRowView " + this.cid);
        filterRowView = _.chain(this.childrenViews).filter(function(view) {
          return view.model.get("row") >= row;
        }).map(function(view) {
          view.model.set("row", view.model.get("row") + 1, {
            validate: true,
            silent: true
          });
          return view;
        }).value();
        return this.getOrAddRowView(row);
      },
      getRowByPosition: function(row) {
        var result;

        result = _.filter(this.childrenViews, function(view) {
          return view.model.get("row") === row;
        });
        if (result.length > 0) {
          return result[0];
        }
      },
      getOrAddRowView: function(row) {
        var filterRowView, model, view;

        log.info("getOrAddRowView " + this.cid);
        filterRowView = _.filter(this.childrenViews, function(view) {
          return view.model.get("row") === row;
        });
        if (filterRowView.length > 0) {
          view = filterRowView[0];
        } else {
          model = this.collection.getOrAddRowModel(row, this.model.get("fieldset"));
          model.set("direction", this.model.get("direction"), {
            validation: true
          });
          view = this.createChild({
            collection: this.collection,
            model: model,
            service: this.options.service
          });
        }
        return view;
      },
      isVisibleDirection: function() {
        log.info("isVisibleDirection");
        return _.chain(this.childrenViews).filter(function(view) {
          return !view.isVisibleDirection();
        }).size().value() <= 0;
      },
      updateDirectionVisible: function() {
        log.info("updateDirectionVisible");
        if (this.isVisibleDirection()) {
          return this.getItem("direction").removeClass("hide");
        } else {
          return this.getItem("direction").addClass("hide");
        }
      },
      /*
      Handle change model (callback Backbone event)
      */

      on_model_change: function(model, options) {
        var changed,
          _this = this;

        log.info("on_model_change " + this.cid);
        changed = _.pick(model.changed, _.keys(model.defaults));
        if (changed.direction != null) {
          _.each(this.childrenViews, function(view) {
            view.model.set("direction", changed.direction, {
              validate: true
            });
            return _this.checkModel(log, view.model);
          });
        }
        _.each(this.childrenViews, function(view, cid) {
          return view.model.set(changed, {
            validate: true
          });
        });
        return this.render();
      },
      /*
      Event to change direction
      */

      event_clickDirection: function() {
        var bVertical, value;

        bVertical = this.model.get('direction') === 'vertical';
        value = bVertical ? "horizontal" : "vertical";
        this.model.set("direction", value, {
          validate: true
        });
        return this.checkModel(log, this.model);
      },
      /*
      Event to change Fieldset legend
      */

      event_inputDataBind: function(e) {
        this.model.set("title", $(e.target).text(), {
          validate: true,
          silent: true
        });
        return this.checkModel(log, this.model);
      },
      /*
      event to destroy view
      */

      event_clickRemove: function() {
        return this.destroy();
      }
    });
  })(UIView, Log.getLogger("view/FieldsetView"));
  return FieldsetView;
});
