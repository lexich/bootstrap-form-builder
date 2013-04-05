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
      if (sortable = @getItem("loader").data("sortable"))
        sortable.destroy()
      Backbone.CustomView::render.apply this, arguments
      connector = @itemsSelectors.loader
      @getItem("loader").sortable
        helper:"original"
        handle:"[data-js-row-move]"
        tolerance:"pointer"
        dropOnEmpty:"true"
        connectWith: connector
        #update: _.bind(@handle_sortable_update,this)
      this



    reindex:->


    ###
    Handle to jQuery.UI.sortable - update
    ###
    handle_sortable_update:(event,ui)->
      LOG "FieldsetView","handle_sortable_update"
      if ui.sender?
        LOG "FieldsetView","handle_sortable_update ui.sender != null"
        formItemView = Backbone.CustomView::staticViewFromEl(ui.item)
        #Если View найден, создаем дочерний
        if formItemView?
          parentView = formItemView.parentView
          #Если произошло перемещение между RowView, устанавливаем текуший
          if parentView != this
            formItemView.setParent this
            parentView.reindex()
            parentView.render()
        else #Иначе создаем новый
          formItemView = @createChild
            el: ui.helper
            model: @createFormItemModel()
            service: @options.service
      @reindex()
      @render()


    ###
    @overwrite Backbone.CustomView
    ###
    childrenViewsOrdered:->
      _.sortBy @childrenViews, (view,cid)-> view.model.get("row")

    ###
    @overwrite Backbone.CustomView
    ###
    reinitialize:->
      fieldset = @model.get("fieldset")
      rows = _.keys @collection.getFieldsetGroupByRow(fieldset)
      childrenCID = _.map rows, (row)=>
        row = toInt row
        view = @getOrAddRowView(row)
        view.reinitialize()
        view.cid

      _.chain(@childrenViews)
        .omit(childrenCID)
        .each (view,cid)=> @removeChild view

    getOrAddRowView:(row)->
      filterRowView = _.filter @childrenViews, (view)->
        view.model.get("row") == row

      if filterRowView.length > 0
        view = filterRowView[0]
      else
        view = @createChild
          collection:@collection
          model: new RowModel {row, fieldset:@model.get("fieldset")}
          service: @options.service
      view

    bindEvents:->
      #bind events

    childrenConnect:(self,view)->
      self.getItem("loader").append view.$el

    event_remove:(e)->
      @destroy()

  FieldsetView