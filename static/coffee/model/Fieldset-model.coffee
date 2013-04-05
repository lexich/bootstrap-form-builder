define [
  "backbone"
],(Backbone)->
  FieldsetModel = Backbone.Model.extend
    defaults:
      fieldset:0
      title:"Default title"
      direction:"horizontal"
    validate:(attrs, options)->
      if attrs.fieldset < 0
        "row must be >= 0"
      else if attrs.title == null or attrs.title == ""
        "title must be not empty"
      else if attrs.direction not in ["horizontal","vertical"]
        "direction must be [horizontal,vertical]"

  FieldsetModel