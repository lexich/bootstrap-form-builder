define [
  "jquery"
  "backbone"
  "underscore"
  "view/DropArea-view"
  "model/DropArea-model"
  "text!../../templates/formView.html"
],($,Backbone,_,DropAreaView, DropAreaModel, templateHtml)->
  FormView = Backbone.View.extend
    events:
      "click [data-js-add-drop-area]": "event_addDropArea"

    dropAreas:{}

    initialize:->
      @options.service.bindForm
        saveForm: => @collection.updateAll()
      @collection.on "reset", => 
        @dropAreas = {}
        @render()  

    render:->
      @$el.html templateHtml
      $placeholder = @getPlaceholder()
      _.chain(@collection.models)
        .groupBy (model)->
          model.get("row")
        .map (models,row)=>
          row = toInt row
          @renderRow row, $placeholder      

    getPlaceholder:-> @$el.find("[data-html-formloader]:first")

    renderRow:(row,$placeholder)->
      row = toInt row
      area = @getOrAddDropArea(row, $placeholder)
      area.render()
      area

    getOrAddDropArea:(row, $placeholder)->
      unless row? then row = _.size(@dropAreas)
      area = @dropAreas[row]
      unless area?
        model = new DropAreaModel row:row

        area = new DropAreaView
          service: @options.service
          model: model
          collection: @collection
          removeDropArea: _.bind(@removeDropArea,this)
          accept:($el)->
            $el.hasClass "ui-draggable"

        model.fetch data: {row:row}
        area.$el.append "<hr/>"
        area.$el.appendTo $placeholder
        @dropAreas[row] = area

      area

    removeDropArea:(row)->
      return false if _.isUndefined(@dropAreas[row])
      delete @dropAreas[row]
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
      true

    event_addDropArea:(e)->
      if _.size(@dropAreas) is 0
        max_key = -1
      else
        max_key = _.chain(@dropAreas).keys().map((key)->parseInt key).max().value();
      @getOrAddDropArea max_key + 1, @getPlaceholder()
      window.scrollTo 0, $(document).height();

  FormView