define [
  "jquery"
  "backbone"
  "underscore"
  "view/Row-view"
  "model/Row-model"
  "common/BackboneCustomView"
],($,Backbone,_,RowView,RowModel)->
  FieldsetView = Backbone.CustomView.extend
    ###
    Variables Backbone.View
    ###
    tagName:"fieldset"
    events:
      "click [data-js-remove-fieldset]": "event_remove"
    ###
    Variables Backbone.CustomView
    ###
    ChildType: RowView
    templatePath:"#FieldsetViewTemplate"
    itemsSelectors:
      loader:"[data-html-fieldset-loader]"

    ###
    @overwrite Backbone.View
    ###
    initialize:->
      @getOrAddRowView(0)
      @bindEvents()

    ###
    @overwrite Backbone.View
    ###
    render:->
      Backbone.CustomView::render.apply this, arguments
      connector = @itemsSelectors.loader
      @getItem("loader").sortable
        helper:"original"
        handle:"[data-js-row-move]"
        tolerance:"pointer"
        dropOnEmpty:"true"
        connectWith: connector
      this


    ###
    @overwrite Backbone.CustomView
    ###
    reinitialize:->
      childrenCID = _.chain(@options.models)
        .groupBy (model)=>
          model.get("row")
        .map (models,row)=>
          row = toInt row
          view = @getOrAddRowView(row, models)
          view.reinitialize()
          view.cid
        .value()
      _.each _.omit(@childrenViews,childrenCID),(view,cid)=>
        @removeChild view

    getOrAddRowView:(row,models)->
      filterRowView = _.filter @childrenViews, (view)->
        view.model.get("row") == row

      if filterRowView.length > 0
        view = filterRowView[0]
      else
        view = @createChild
          collection:@collection
          model: new RowModel {row, fieldset:@model.get("fieldset")}
          models: models
          service: @options.service

      view.models = models
      view

    bindEvents:->
      #bind events

    childrenConnect:(self,view)->
      self.getItem("loader").append view.$el

    event_remove:(e)->
      @destroy()

  FieldsetView