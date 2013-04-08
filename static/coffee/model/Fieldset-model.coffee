define [
  "backbone"
],(Backbone)->
  FieldsetModel = Backbone.Model.extend
    modelname:"FieldsetModel"
    defaults:
      fieldset:0
      title:"Default title"
    validate:(attrs, options)->
      if attrs.fieldset < 0
        "row must be >= 0"
      else if attrs.title == null or attrs.title == ""
        "title must be not empty"

  FieldsetModel