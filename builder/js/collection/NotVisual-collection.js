define(["backbone", "underscore", "model/NotVisual-model"], function(Backbone, _, NotVisualModel) {
  var NotVisualCollection;

  NotVisualCollection = Backbone.Collection.extend({
    model: NotVisualModel,
    addModel: function(data) {
      var model;

      model = new NotVisualModel(data);
      this.add(model);
      return model;
    }
  });
  return NotVisualCollection;
});
