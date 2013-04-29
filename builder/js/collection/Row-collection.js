define(["backbone", "underscore", "model/Row-model"], function(Backbone, _, RowModel) {
  var RowCollection;

  RowCollection = Backbone.Collection.extend({
    model: RowModel,
    getRow: function(row, fieldset) {
      var item, result;

      result = this.where({
        row: row,
        fieldset: fieldset
      });
      if (result.length > 0) {
        return result[0];
      } else {
        item = new this.model({
          row: row,
          fieldset: fieldset
        });
        this.add(item);
        return item;
      }
    }
  });
  return RowCollection;
});
