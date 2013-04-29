define(["backbone", "underscore", "model/FormItem-model", "collection/Fieldset-collection", "collection/Row-collection", "collection/NotVisual-collection", "common/Log"], function(Backbone, _, FormItemModel, FieldsetCollection, RowCollection, NotVisualCollection, Log) {
  var FormItemCollection, log;

  log = Log.getLogger("collection/FormItemCollection");
  FormItemCollection = Backbone.Collection.extend({
    DEFAULT_URL: "/forms.json",
    model: FormItemModel,
    fieldsetCollection: new FieldsetCollection,
    rowCollection: new RowCollection,
    notVisualCollection: new NotVisualCollection,
    initialize: function(options) {
      return this.url = options.url ? options.url : this.DEFAULT_URL;
    },
    parse: function(response) {
      var fieldsets, itemsMap, key, keys, notvisual, result, row, rows, _i, _len;

      if (rows = response.rows) {
        this.rowCollection.add(this.rowCollection.parse != null ? this.rowCollection.parse(rows) : rows);
      }
      if (fieldsets = response.fieldsets) {
        this.fieldsetCollection.add(this.fieldsetCollection.parse != null ? this.fieldsetCollection.parse(fieldsets) : fieldsets);
      }
      if (notvisual = response.notvisual) {
        this.notVisualCollection.add(this.notVisualCollection.parse != null ? this.notVisualCollection.parse(notvisual) : notvisual);
      }
      itemsMap = _.groupBy(response.items, function(item) {
        return item.row;
      });
      keys = _.chain(itemsMap).keys().map(function(key) {
        return parseInt(key);
      }).value().sort();
      row = 0;
      result = [];
      for (_i = 0, _len = keys.length; _i < _len; _i++) {
        key = keys[_i];
        _.each(itemsMap[key], function(item) {
          item.row = row;
          return result.push(item);
        });
        row++;
      }
      return result;
    },
    toJSON: function(options) {
      var fieldsets, img, items, notvisual, rows, _ref;

      items = Backbone.Collection.prototype.toJSON.apply(this, arguments);
      rows = this.rowCollection.toJSON();
      fieldsets = this.fieldsetCollection.toJSON();
      notvisual = this.notVisualCollection.toJSON();
      img = (_ref = options.img) != null ? _ref : "data:image/png;base64,";
      return {
        items: items,
        rows: rows,
        fieldsets: fieldsets,
        notvisual: notvisual,
        img: img
      };
    },
    comparator: function(model) {
      return model.get("row") * 1000 + model.get("position");
    },
    updateAll: function(options) {
      var _this = this;

      options = _.extend(options || {}, {
        success: function(model, resp, xhr) {
          return _this.reset(model);
        }
      });
      return Backbone.sync('create', this, options);
    },
    smartSliceNormalize: function(row, key, baseValue) {
      var groups, keys, models,
        _this = this;

      models = this.where({
        row: row
      });
      groups = _.groupBy(models, function(model) {
        return model.get(key);
      });
      keys = _.keys(groups);
      if (keys.length > 1) {
        _.each(models, function(model) {
          return model.set(key, baseValue, {
            validation: true,
            silent: true
          });
        });
      }
      return models;
    },
    remove: function(models, options) {
      var model;

      log.info("remove");
      if (_.isArray(models)) {
        if (models.length <= 0) {
          return Backbone.Collection.prototype.remove.apply(this, arguments);
        } else {
          model = models[0];
        }
      } else if (_.isObject(models)) {
        model = models;
      }
      if (model.modelname === this.model.prototype.modelname) {
        return Backbone.Collection.prototype.remove.apply(this, arguments);
      } else if (model.modelname === this.fieldsetCollection.model.prototype.modelname) {
        return this.fieldsetCollection.remove(models, options);
      } else if (model.modelname === this.rowCollection.model.prototype.modelname) {
        return this.rowCollection.remove(models, options);
      } else if (model.modelname === this.notVisualCollection.model.prototype.modelname) {
        return this.notVisualCollection.remove(model, options);
      }
    },
    getRow: function(fieldset, row) {
      return _.filter(this.models, function(model) {
        return (model.get("fieldset") === fieldset) && (model.get("row") === row);
      });
    },
    getFieldset: function(fieldset) {
      return _.filter(this.models, function(model) {
        return model.get("fieldset") === fieldset;
      });
    },
    getFieldsetGroupByRow: function(fieldset) {
      return _.groupBy(this.getFieldset(fieldset), function(model) {
        return model.get("row");
      });
    },
    getOrAddFieldsetModel: function(fieldset) {
      return this.fieldsetCollection.getFieldset(fieldset);
    },
    getOrAddRowModel: function(row, fieldset) {
      return this.rowCollection.getRow(row, fieldset);
    },
    addNotVisualModel: function(data) {
      return this.notVisualCollection.addModel(data);
    }
  });
  return FormItemCollection;
});
