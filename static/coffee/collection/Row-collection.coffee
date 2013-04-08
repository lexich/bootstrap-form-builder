define [
   "backbone"
   "underscore"
   "model/Row-model"
],(Backbone,_, RowModel)->

  RowCollection = Backbone.Collection.extend
    model:RowModel
    getRow:(row,fieldset)->
      result = @where row:row, fieldset:fieldset
      if result.length > 0
        result[0]
      else
        item = new @model {row, fieldset:fieldset}
        @add item
        item

  RowCollection