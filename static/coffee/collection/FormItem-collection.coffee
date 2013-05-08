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

    childCollection:
      fieldsets:new FieldsetCollection #fieldsetCollection
      rows: new RowCollection #rowCollection
      notvisual: new NotVisualCollection #notVisualCollection

    parse:(response)->
      _.each @childCollection, (collection,k)->
        if item = response[k]
          collection.add if collection.parse?
            collection.parse item
          else item

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
      result =
        items: Backbone.Collection::toJSON.apply(this,arguments)
        img: options?.img ? "data:image/png;base64,"
      _.each @childCollection,(collection,k)->
        result[k] = collection.toJSON()
      result
    
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
      else
        _.chain(@childCollection)\
          .filter(
            (collection)-> model.modelname is collection.model::modelname)\
          .map(
            (collection)-> collection.remove models, options)\
          .value()


    getRow:(fieldset, row)->
      _.filter @models,(model)->
        (model.get("fieldset") is fieldset) and (model.get("row") is row)

    getFieldset:(fieldset)->
      _.filter @models,(model)->
        (model.get("fieldset") is fieldset)

    getFieldsetGroupByRow:(fieldset)->
      _.groupBy @getFieldset(fieldset), (model)-> model.get("row")

    getOrAddFieldsetModel:(fieldset)->
      @childCollection.fieldsets.getFieldset fieldset

    getOrAddRowModel:(row,fieldset)->
      @childCollection.rows.getRow row, fieldset

    addNotVisualModel:(data)->
      @childCollection.notvisual.addModel(data)


  FormItemCollection