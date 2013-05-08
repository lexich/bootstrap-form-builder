define [
  "backbone"
  "underscore"
  "model/FormItem-model"
  "collection/Fieldset-collection"
  "collection/Row-collection"
  "collection/NotVisual-collection"
  "common/Log"
],(Backbone,_, FormItemModel, FieldsetCollection,RowCollection, NotVisualCollection, Log)->

  log = Log.getLogger("collection/FormItemCollection")

  FormItemCollection = Backbone.Collection.extend
    url:"/forms.json"
    model : FormItemModel
    fieldsetCollection:new FieldsetCollection
    rowCollection: new RowCollection
    notVisualCollection: new NotVisualCollection

    parse:(response)->
      if rows = response.rows
        @rowCollection.add if @rowCollection.parse?
          @rowCollection.parse rows
        else rows

      if fieldsets = response.fieldsets
        @fieldsetCollection.add if @fieldsetCollection.parse?
          @fieldsetCollection.parse fieldsets
        else fieldsets

      if notvisual = response.notvisual
        @notVisualCollection.add if @notVisualCollection.parse?
          @notVisualCollection.parse notvisual
        else notvisual

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

    toJSON:(options)->
      items = Backbone.Collection::toJSON.apply(this,arguments)
      rows = @rowCollection.toJSON()
      fieldsets = @fieldsetCollection.toJSON()
      notvisual = @notVisualCollection.toJSON()
      img = options?.img ? "data:image/png;base64,"
      {items,rows,fieldsets,notvisual,img}
    
    comparator:(model)->
      model.get("row") * 1000 + model.get("position")

    updateAll:(options)->
      options = _.extend options or {},
        success: (model, resp, xhr)=>
          @reset(model)
      Backbone.sync 'create', this, options

    remove:(models, options)->
      log.info "remove"
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
      else if model.modelname is @notVisualCollection.model::modelname
        @notVisualCollection.remove model, options

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

    addNotVisualModel:(data)->
      @notVisualCollection.addModel(data)


  FormItemCollection