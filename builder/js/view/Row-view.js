define(["jquery", "backbone", "underscore", "view/FormItem-view", "model/FormItem-model", "model/DropArea-model", "common/Log", "sortable", "common/BackboneCustomView"], function($, Backbone, _, FormItemView, FormItemModel, DropAreaModel, Log) {
  var RowView, RowViewCustomView, RowViewSortableHandlers;

  RowViewCustomView = (function(__super__, log) {
    return __super__.extend({
      viewname: "row",
      templatePath: "#RowViewTemplate",
      ChildType: FormItemView,
      itemsSelectorsCache: false,
      itemsSelectors: {
        area: "[data-drop-accept]",
        areaChildren: "[data-drop-accept] >",
        placeholderItem: ".ui_formitem__placeholder",
        directionMode: "[data-js-row-position]",
        ghostRow: "[data-ghost-row]"
      },
      childrenViewsOrdered: function() {
        return _.sortBy(this.childrenViews, function(view, cid) {
          return view.model.get("position");
        });
      },
      templateData: function() {
        return _.extend(this.model.toJSON(), {
          cid: this.cid
        });
      },
      updateViewModes: function() {
        var $area, $el, bDisable, bVertical, connectWith, freeSize, _ref;

        log.info("updateViewModes " + this.viewname + ":" + this.cid);
        __super__.prototype.updateViewModes.apply(this, arguments);
        $area = this.getItem("area");
        bVertical = this.model.get('direction') === "vertical";
        $el = this.getItem("directionMode");
        if (bVertical) {
          this.$el.removeClass("form-horizontal");
          this.getItem("ghostRow").removeClass("form-horizontal");
          $el.addClass("icon-resize-horizontal").removeClass("icon-resize-vertical");
          if (_.size(this.childrenViews) > 1) {
            $el.addClass("hide");
          } else {
            $el.removeClass("hide");
          }
        } else {
          this.$el.addClass("form-horizontal");
          this.getItem("ghostRow").addClass("form-horizontal");
          $el.addClass("icon-resize-vertical").removeClass("icon-resize-horizontal");
        }
        connectWith = "[data-drop-accept]:not([" + this.DISABLE_DRAG + "]),[data-drop-accept-placeholder]";
        if ((_ref = $area.data("sortable")) != null) {
          _ref.destroy();
        }
        $area.sortable({
          helper: "original",
          tolerance: "pointer",
          handle: "[data-js-formitem-move]",
          dropOnEmpty: true,
          placeholder: "ui_formitem__placeholder",
          change: _.bind(this.handle_sortable_change, this),
          connectWith: connectWith,
          start: _.bind(this.handle_sortable_start, this),
          stop: _.bind(this.handle_sortable_stop, this),
          over: _.bind(this.handle_sortable_over, this),
          update: _.bind(this.handle_sortable_update, this),
          activate: _.bind(this.handle_sortable_activate, this),
          deactivate: _.bind(this.handle_sortable_deactivate, this)
        });
        bDisable = false;
        if (bVertical) {
          freeSize = this.getCurrentFreeRowSize();
          if (freeSize <= 1) {
            bDisable = true;
          }
        } else {
          bDisable = true;
        }
        return this.setDisable(bDisable);
      },
      getPreviousRow: function(view) {
        return this.parentView.getRowByPosition(view.model.get("row") - 1);
      },
      getNextRow: function(view) {
        return this.parentView.getRowByPosition(view.model.get("row") + 1);
      },
      reinitialize: function() {
        var models,
          _this = this;

        log.info("reinitialize " + this.viewname + ":" + this.cid);
        models = this.collection.getRow(this.model.get("fieldset"), this.model.get("row"));
        return _.each(models, function(model) {
          var view;

          view = _this.getOrAddChildTypeByModel(model);
          return view.reinitialize();
        });
      },
      handle_create_new: function(event, ui) {
        var componentType, data, position, row, size, view, _ref;

        log.info("handle_create_new " + this.viewname + ":" + this.cid);
        view = __super__.prototype.staticViewFromEl(ui.item);
        size = this.getCurrentFreeRowSize();
        if ((view != null) && view.viewname === "formitem") {
          if (ui.item.parent().is('[data-ghost-row]')) {
            row = this.parentView.insertRow(this.model.get("row"));
            data = {
              fieldset: row.model.get('fieldset'),
              row: row.model.get('row'),
              position: 0
            };
            row.addChild(view);
            view.model.set(data, {
              validate: true
            });
            this.checkModel(log, view.model);
            row.parentView.render();
          } else {
            position = _.size(this.childrenViews);
            data = {
              fieldset: this.model.get('fieldset'),
              row: this.model.get('row'),
              position: position
            };
            if (size < 3) {
              data.size = size;
            }
            this.addChild(view);
            view.model.set(data, {
              validate: true
            });
            this.checkModel(log, view.model);
          }
        } else {
          componentType = $(ui.item).data("componentType");
          data = this.options.service.getTemplateData(componentType);
          if (ui.item.parent().is('[data-ghost-row]')) {
            row = this.parentView.insertRow(this.model.get("row"));
            row.createChild({
              model: row.createFormItemModel(data),
              service: row.options.service,
              collection: row.collection
            });
            row.parentView.render();
            if ((_ref = ui.helper) != null) {
              _ref.remove();
            }
          } else {
            view = this.createChild({
              model: this.createFormItemModel(data),
              service: this.options.service,
              collection: this.collection
            });
          }
        }
        return this;
      },
      reindex: function() {
        var _this = this;

        log.info("reindex " + this.viewname + ":" + this.cid);
        return _.reduce(this.getItem("areaChildren"), (function(position, el) {
          var direction, fieldset, row, view, _ref;

          if ((view = __super__.prototype.staticViewFromEl(el))) {
            row = _this.model.get("row");
            fieldset = _this.model.get("fieldset");
            direction = _this.model.get("direction");
            if ((_ref = view.model) != null) {
              _ref.set({
                position: position,
                row: row,
                fieldset: fieldset,
                direction: direction
              }, {
                validate: true
              });
            }
          }
          return position + 1;
        }), 0);
      },
      addChild: function(view) {
        var result;

        log.info("addChild " + this.viewname + ":" + this.cid);
        result = __super__.prototype.addChild.apply(this, arguments);
        if (view.model) {
          view.model.set("direction", this.model.get("direction"), {
            validate: true,
            silent: true
          });
          this.checkModel(log, view.model);
          this.listenTo(view.model, "change:size", this.on_child_model_changes_size);
        }
        this.parentView.updateDirectionVisible();
        return result;
      },
      removeChild: function(view) {
        var result;

        log.info("removeChild " + this.viewname + ":" + this.cid);
        result = __super__.prototype.removeChild.apply(this, arguments);
        this.stopListening(view != null ? view.model : void 0, "change:size", this.on_child_model_changes_size);
        return result;
      },
      childrenConnect: function(self, view) {
        log.info("childrenConnect " + this.viewname + ":" + this.cid);
        return view.$el.appendTo(self != null ? self.getItem("area") : void 0);
      }
    });
  })(Backbone.CustomView, Log.getLogger("view/RowViewCustomView"));
  RowViewSortableHandlers = (function(__super__, log) {
    return __super__.extend({
      handle_sortable_change: function(event, ui) {
        var freesize, size, view;

        log.info("handle_sortable_change " + this.cid);
        freesize = this.getCurrentFreeRowSize();
        size = 3;
        if ((view = __super__.prototype.staticViewFromEl(ui.item))) {
          size = view.model.get("size");
          if (view.parentView !== this) {
            if (size > freesize) {
              size = freesize;
            }
          }
        } else {
          if (freesize <= 3) {
            size = freesize;
          }
        }
        return this.cleanSpan(ui.placeholder).addClass("span" + size);
      },
      handle_sortable_over: function(event, ui) {
        var _ref;

        $("[data-ghost-row]").hide();
        if (!(((_ref = this.getPreviousRow(this)) != null ? _ref.$el.is(this.originParent) : void 0) && _.size(this.getPreviousRow(this).childrenViews) <= 1)) {
          if (!this.$el.is(this.originParent) || _.size(this.childrenViews) > 1) {
            this.getItem("ghostRow").show().sortable("refreshPositions");
          }
        }
        return true;
      },
      handle_sortable_deactivate: function(event, ui) {
        this.getItem("area").removeClass("ui_row__loader_active");
        this.getItem("ghostRow").hide();
        return this.originParent = null;
      },
      handle_sortable_activate: function(event, ui) {
        var _ref;

        this.originParent = (_ref = ui.sender) != null ? _ref.closest("." + this.className) : void 0;
        if (!this.getItem("area").is("[" + this.DISABLE_DRAG + "]")) {
          return this.getItem("area").addClass("ui_row__loader_active");
        }
      },
      handle_sortable_update: function(event, ui) {
        var componentType, data, formItemView, freesize, model, parentView;

        log.info("handle_sortable_update " + this.viewname + ":" + this.cid);
        formItemView = __super__.prototype.staticViewFromEl(ui.item);
        if (ui.sender != null) {
          log.info("handle_sortable_update " + this.viewname + ":" + this.cid + " ui.sender != null");
          if (formItemView != null) {
            parentView = formItemView.parentView;
            if ((model = formItemView.model)) {
              freesize = this.getCurrentFreeRowSize();
              if (model.get("size") > freesize) {
                model.set("size", freesize, {
                  validate: true,
                  silent: true
                });
                this.checkModel(log, model);
              }
            }
            if (parentView !== this) {
              this.addChild(formItemView);
              this.reindex();
            }
          }
        }
        if (formItemView == null) {
          componentType = $(ui.item).data("componentType");
          freesize = this.getCurrentFreeRowSize();
          data = this.options.service.getTemplateData(componentType);
          if (data.size > freesize) {
            data.size = freesize;
          }
          formItemView = this.createChild({
            model: this.createFormItemModel(data),
            collection: this.collection,
            service: this.options.service
          });
          ui.item.replaceWith(formItemView.$el);
          this.reindex();
          return this.render();
        }
      }
    });
  })(RowViewCustomView, Log.getLogger("view/RowViewSortableHandlers"));
  RowView = (function(__super__, log) {
    return __super__.extend({
      SELECTED_CLASS: "ui_row__selected",
      DISABLE_DRAG: "data-js-row-disable-drag",
      placeholderSelector: "[data-drop-accept-placeholder]:not([data-ghost-row])",
      /*
      Variables Backbone.View
      */

      events: {
        "click [data-js-row-disable]": "event_disable",
        "click [data-js-row-position]": "event_direction",
        "click [data-js-row-remove]": "event_remove",
        "mouseenter [data-drop-accept]": "event_mouseEnter"
      },
      className: "ui_row",
      initialize: function() {
        return this.model.on("change", _.bind(this.on_model_change, this));
      },
      setSelected: function(bValue) {
        if (bValue) {
          return this.$el.addClass(this.SELECTED_CLASS);
        } else {
          return this.$el.removeClass(this.SELECTED_CLASS);
        }
      },
      setDisable: function(flag) {
        var $area;

        log.info("setDisable " + this.viewname + ":" + this.cid);
        if (flag == null) {
          flag = true;
        }
        $area = this.getItem("area");
        if (flag) {
          return $area.attr(this.DISABLE_DRAG, "");
        } else {
          return $area.removeAttr(this.DISABLE_DRAG);
        }
      },
      /*
      create new model FormItemModel
      @return FormItemModel
      */

      createFormItemModel: function(data) {
        var freesize, model;

        log.info("createFormItemModel " + this.viewname + ":" + this.cid);
        freesize = this.getCurrentFreeRowSize();
        data = _.extend(data || {}, {
          row: this.model.get("row"),
          fieldset: this.model.get("fieldset")
        });
        model = new FormItemModel(data);
        if (model.get("size") > freesize) {
          model.set("size", freesize, {
            validate: true,
            silence: true
          });
        }
        this.collection.add(model);
        return model;
      },
      getCurrentRowSize: function() {
        return _.reduce(this.childrenViews, (function(asize, view) {
          return view.model.get("size") + asize;
        }), 0);
      },
      getCurrentFreeRowSize: function() {
        return 12 - this.getCurrentRowSize();
      },
      getOrAddChildTypeByModel: function(model) {
        var view, views;

        log.info("getOrAddChildTypeByModel " + this.viewname + ":" + this.cid);
        views = _.filter(this.childrenViews, function(view, cid) {
          return view.model === model;
        });
        if (views.length > 0) {
          view = views[0];
        } else {
          view = this.createChild({
            model: model,
            collection: this.collection,
            service: this.options.service
          });
        }
        return view;
      },
      isVisibleDirection: function() {
        return _.size(this.childrenViews) <= 1;
      },
      /*
      Bind to child models on "change:size" event
      */

      on_child_model_changes_size: function(model, size) {
        log.info("on_child_model_changes_size " + this.viewname + ":" + this.cid);
        return this.updateViewModes();
      },
      /*
      Bind to current model on "change" event
      */

      on_model_change: function(model, options) {
        var changed,
          _this = this;

        log.info("on_model_change " + this.viewname + ":" + this.cid);
        changed = _.pick(model.changed, _.keys(model.defaults));
        _.each(this.childrenViews, function(view, cid) {
          view.model.set(changed, {
            validate: true
          });
          return _this.checkModel(log, view.model);
        });
        if (changed.direction) {
          return this.updateViewModes();
        }
      },
      event_disable: function(e) {
        log.info("event_disable " + this.viewname + ":" + this.cid);
        if (this._disable == null) {
          this._disable = false;
        }
        this._disable = !this._disable;
        $(e.target).text(this._disable ? "Disabled" : "Enabled");
        return this.setDisable(this._disable);
      },
      event_direction: function(e) {
        var value;

        log.info("event_direction " + this.viewname + ":" + this.cid);
        value = this.model.get('direction') === 'vertical' ? "horizontal" : "vertical";
        this.model.set("direction", value, {
          validate: true
        });
        return this.checkModel(log, this.model);
      },
      event_remove: function() {
        log.info("event_remove " + this.viewname + ":" + this.cid);
        return this.remove();
      },
      event_mouseEnter: function() {
        if (this.dragActive && this.getItem("area").is("[" + this.DISABLE_DRAG + "]")) {
          $("[data-ghost-row]").hide();
          return this.getItem("ghostRow").show().sortable("refreshPositions");
        }
      }
    });
  })(RowViewSortableHandlers, Log.getLogger("view/RowView"));
  return RowView;
});
