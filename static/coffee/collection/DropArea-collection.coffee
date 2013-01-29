define [
  "backbone"
  "underscore"
  "/static/js/model/DropArea-model.js"
],(Backbone,_, DropAreaModel)->

  DropAreaCollection = Backbone.Collection.extend
    DEFAULT_URL:"/forms.json"
    model : DropAreaModel

    parse:(response)-> 
      itemsMap = _.groupBy response, (item)->item.row
      keys = _.chain(itemsMap)
        .keys()
        .map (key)->
          parseInt key
        .value().sort()
      row = 0
      result = []
      for key in keys        
        _.each itemsMap[key],(item)->          
          item.row = row
          result.push item
        row++
      result
      

    initialize:(options)->
      @url = if options.url then options.url else @DEFAULT_URL
    
    comparator:(model)->
      model.get("row") * 1000 + model.get("position")

    updateAll: ->
      options =
        success: (model, resp, xhr)=>
          @reset(model)
      Backbone.sync 'create', this, options

  DropAreaCollection