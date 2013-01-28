define [
  "backbone",
  "/static/js/model/DropArea-model.js"
],(Backbone,DropAreaModel)->

  DropAreaCollection = Backbone.Collection.extend
    url : "/forms.json"
    model : DropAreaModel
    parse:(attrs,options)->
      attrs
    comparator:(model)->
      model.get("row") * 1000 + model.get("position")
    updateAll: ->
      options =
        success: (model, resp, xhr)=>
          @reset(model)
      Backbone.sync 'create', this, options

  DropAreaCollection