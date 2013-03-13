define [
  "backbone"
  "underscore"
  "model/DropArea-model"
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

    updateAll:->      
      options =
        success: (model, resp, xhr)=>
          @reset(model)
      Backbone.sync 'create', this, options

    smartSliceNormalize:(row,key,baseValue)->
      models = @where row:row
      groups = _.groupBy models, (model)-> model.get(key)
      keys = _.keys(groups)
      if keys.length > 1
        _.each models,(model)=>
          model.set key, baseValue, {
            validation:true
            silent: true
          }
      models

  DropAreaCollection