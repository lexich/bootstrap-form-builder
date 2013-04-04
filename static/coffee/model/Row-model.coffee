define [
  "backbone"
],(Backbone)->
  RowModel = Backbone.Model.extend
    defaults:
      row: 0
      fieldset:0
    validate:(attrs, options)->
      if attrs.row < 0
        "row must be >= 0"
      if attrs.fieldset < 0
        "fieldset must be >= 0"

  RowModel