define [
  "backbone"
  "underscore"
  "model/NotVisual-model"
],(Backbone,_, NotVisualModel)->

  NotVisualCollection = Backbone.Collection.extend
    model:NotVisualModel
    addModel:(data)->
      model = new NotVisualModel(data)
      @add model
      model

  NotVisualCollection