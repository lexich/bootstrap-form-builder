define [
  "jquery",
  "backbone",
  "underscore",
  "view/DropArea-view"
],($,Backbone,_,DropAreaView)-> 
  FormView = Backbone.View.extend
    events:
      "click [data-js-submit-form]": "event_submitForm"
      "click [data-js-add-drop-area]": "event_addDropArea"

    dropAreas:{}

    initialize:->
      @collection.on "reset", _.bind(@_resetCollection,this)

    _resetCollection:->
      ###
      index models in row
      ###    
      rowModels = _.groupBy(@collection.models,(model)->
          model.get("row")
      )
      _.each rowModels,(models,row)=>
        models = _.sortBy(models, (model)-> model.get("position"))
        _.reduce models,((prev,model)->
          model.set {position:prev+1},{silent:true}
          prev + 1
        ),-1
        row = toInt row
        area = @getOrAddDropArea(row)
        area.render()
        area

    getOrAddDropArea:(row)->
      unless row? then row = _.size(@dropAreas)
      area = @dropAreas[row]
      unless area?        
        area = new DropAreaView          
          service: @options.service
          collection: @collection
          formview:this
          row:row
          accept:($el)->
            $el.hasClass "ui-draggable"
        area.$el.appendTo @$el
        @dropAreas[row] = area      
      area

    removeDropArea:(area)->
      delete @dropAreas[area.row]
      newDropAreas = {}
      _.chain(@dropAreas)
        .sortBy((area,k)->area.row)
        .reduce((
          (memo,area)->
            newDropAreas[memo] = area
            area.setRow memo
            memo + 1
        ),0)
      @dropAreas = newDropAreas


    event_submitForm:(e)->
      @collection.updateAll()

    event_addDropArea:(e)->
      keys = _.keys(@dropAreas)
      nextRow = if keys.length > 0 then parseInt(_.max(keys))+1 else 0
      @getOrAddDropArea nextRow
  FormView