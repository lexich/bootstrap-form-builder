define [
  "backbone"
  "underscore"
  "model/Fieldset-model"
],(Backbone,_, FieldsetModel)->

  FieldsetCollection = Backbone.Collection.extend
    model:FieldsetModel
    getFieldset:(fieldset)->
      result = @where fieldset:fieldset
      if result.length > 0
        result[0]
      else
        item = new @model fieldset:fieldset
        @add item
        item

  FieldsetCollection