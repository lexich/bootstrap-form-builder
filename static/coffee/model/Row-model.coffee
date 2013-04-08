define [
  "backbone"
],(Backbone)->
  RowModel = Backbone.Model.extend
    modelname:"RowModel"
    defaults:
      row: 0
      fieldset:0
      direction:"horizontal"
    validate:(attrs, options)->
      if attrs.row < 0
        "row must be >= 0"
      else if attrs.fieldset < 0
        "fieldset must be >= 0"
      else if attrs.direction not in ["horizontal","vertical"]
        "direction must be [horizontal,vertical]"

  RowModel