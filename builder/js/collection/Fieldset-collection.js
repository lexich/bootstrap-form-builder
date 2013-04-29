define(["backbone", "underscore", "model/Fieldset-model", "common/Log"], function(Backbone, _, FieldsetModel, Log) {
  var FieldsetCollection, log;

  log = Log.getLogger("collection/FieldsetCollection");
  FieldsetCollection = Backbone.Collection.extend({
    model: FieldsetModel,
    getFieldset: function(fieldset) {
      var item, result;

      result = this.where({
        fieldset: fieldset
      });
      if (result.length > 0) {
        return result[0];
      } else {
        item = new this.model({
          fieldset: fieldset
        });
        this.add(item);
        return item;
      }
    }
  });
  return FieldsetCollection;
});
