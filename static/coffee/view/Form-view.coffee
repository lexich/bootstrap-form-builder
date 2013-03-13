define [
  "jquery",
  "backbone",
  "underscore",
  "view/DropArea-view"
  "text!../../templates/formView.html"
],($,Backbone,_,DropAreaView,templateHtml)-> 
  FormView = Backbone.View.extend
    events:
      "click [data-js-submit-form]": "event_submitForm"
      "click [data-js-add-drop-area]": "event_addDropArea"
      "click [data-js-show-debug]": "event_showDebug"
    dropAreas:{}

    initialize:->            
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
        area = new DropAreaView
          service: @options.service
          collection: @collection
          removeDropArea: _.bind(@removeDropArea,this)
          row:row
          accept:($el)->
            $el.hasClass "ui-draggable"
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

    event_submitForm:(e)->
      @collection.updateAll()

    event_addDropArea:(e)->
      max_key = _.chain(@dropAreas).keys().map((key)->parseInt key).max().value();
      @getOrAddDropArea max_key + 1, @getPlaceholder()
      window.scrollTo 0, $(document).height();

    event_showDebug:(e)->
      $("body").toggleClass("debug")
      $(e.target).toggleClass("btn-link")




  FormView