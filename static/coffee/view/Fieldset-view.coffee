define [
  "jquery"
  "backbone"
  "underscore"
  "view/Row-view"
  "model/Row-model"
  "common/BackboneCustomView"
],($,Backbone,_,RowView,RowModel)->
  FieldsetView = Backbone.CustomView.extend
    ChildType: RowView
    templatePath:"#FieldsetViewTemplate"
    itemsSelectors:
      placeholder:"[data-html-fieldset-placeholder]"

    events:
      "click [data-js-remove-fieldset]": "event_remove"

    initialize:->
      @bindEvents()

    reinitialize:->
      childrenCID = _.chain(@options.models)
        .groupBy (model)=>
          model.get("row")
        .map (models,row)=>
          row = toInt row
          view = @getOrAddRowView(row, models)
          view.cid
        .value()
      _.each _.omit(@childrenViews,childrenCID),(view,cid)=>
        @removeChild view

    getOrAddRowView:(row,models)->
      unless (view=@findChildViewByRow(row))
        view = @createChild
          collection:@collection
          model: new RowModel {row, fieldset:@model.get("fieldset")}
          models: models
      view.models = models
      view

    findChildViewByRow:(row)->


    bindEvents:->
      #bind events

    childrenConnect:(self,view)->
      $placeholder = self.getItem("placeholder")
      $placeholder.append view.$el

    event_remove:(e)->
      @destroy()

  FieldsetView