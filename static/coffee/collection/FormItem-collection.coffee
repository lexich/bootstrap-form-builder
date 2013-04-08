define [
  "backbone"
  "underscore"
  "model/FormItem-model"
  "collection/Fieldset-collection"
  "collection/Row-collection"
],(Backbone,_, FormItemModel, FieldsetCollection,RowCollection)->

  FormItemCollection = Backbone.Collection.extend
    DEFAULT_URL:"/forms.json"
    model : FormItemModel
    fieldsetCollection:new FieldsetCollection
    rowCollection: new RowCollection

    initialize:(options)->
      @url = if options.url then options.url else @DEFAULT_URL

    parse:(response)->
      @rowCollection.add if @rowCollection.parse?
        @rowCollection.parse response.rows
      else response.rows

      @fieldsetCollection.add if @fieldsetCollection.parse?
        @fieldsetCollection.parse response.fieldsets
      else response.fieldsets

      itemsMap = _.groupBy response.items, (item)->item.row
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

    toJSON:->
      items = Backbone.Collection::toJSON.apply(this,arguments)
      rows = @rowCollection.toJSON()
      fieldsets = @fieldsetCollection.toJSON()
      {items,rows,fieldsets}
    
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

    remove:(models, options)->
      if _.isArray(models)
        if models.length <= 0
          return Backbone.Collection::remove.apply this, arguments
        else
          model = models[0]
      else if _.isObject models
        model = models

      if model.modelname is @model::modelname
        Backbone.Collection::remove.apply this, arguments
      else if model.modelname is @fieldsetCollection.model::modelname
        @fieldsetCollection.remove models, options
      else if model.modelname is @rowCollection.model::modelname
        @rowCollection.remove models, options

    getRow:(fieldset, row)->
      _.filter @models,(model)->
        (model.get("fieldset") is fieldset) and (model.get("row") is row)

    getFieldset:(fieldset)->
      _.filter @models,(model)->
        (model.get("fieldset") is fieldset)

    getFieldsetGroupByRow:(fieldset)->
      _.groupBy @getFieldset(fieldset), (model)-> model.get("row")

    getOrAddFieldsetModel:(fieldset)->
      @fieldsetCollection.getFieldset fieldset

    getOrAddRowModel:(row,fieldset)->
      @rowCollection.getRow row, fieldset


  FormItemCollection