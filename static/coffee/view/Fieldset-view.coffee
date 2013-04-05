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
      loaderChildren:"[data-html-fieldset-loader] >"

    ###
    @overwrite Backbone.View
    ###
    initialize:->
      @getOrAddRowView(0)
      @bindEvents()
      @model.on "change", _.bind(@on_model_change,this)

    on_model_change:(model,options)->
      changed = _.pick model.changed, _.keys(model.defaults)
      _.each @childrenViews,(view,cid)->
        #silent mode freeze changing beause render call
        view.model.set changed,{validate:true}

    ###
    @overwrite Backbone.View
    ###
    render:->
      LOG "Fieldset", "render #{@cid}"
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
        start:_.bind(@handle_sortable_start, this)
        stop: _.bind(@handle_sortable_stop, this)
        update: _.bind(@handle_sortable_update,this)
      this

    reindex:->
      LOG "RowView","reindex #{@cid}"
      _.reduce @getItem("loaderChildren"), ((row,el)=>
        if(view = Backbone.CustomView::staticViewFromEl el)
          view.model?.set {
            row: row
            fieldset: @model.get "fieldset"
            direction: @model.get "direction"
          }, {validate: true}
        row + 1
      ),0

      ###
      Handle to jQuery.UI.sortable - start
      ###
    handle_sortable_start:->
      LOG "FieldsetView","handle_sortable_start #{@cid}"

    ###
    Handle to jQuery.UI.sortable - stop
    ###
    handle_sortable_stop:(event,ui)->
      LOG "FieldsetView","handle_sortable_stop #{@cid}"
      @reindex()

    ###
    Handle to jQuery.UI.sortable - update
    ###
    handle_sortable_update:(event,ui)->
      LOG "FieldsetView","handle_sortable_update #{@cid}"
      rowView = Backbone.CustomView::staticViewFromEl(ui.item)
      if ui.sender?
        LOG "RowView","handle_sortable_update #{@cid} ui.sender != null"
        #Если View найден, создаем дочерний
        if rowView
          parentView = rowView.parentView
          #Если произошло перемещение между FieldsetView, устанавливаем текуший
          if parentView != this
            rowView.setParent this
            @reindex()
        else #Иначе создаем новый
          rowView = @createChild
            el: ui.helper
            model: new RowModel {fieldset:@model.get("fieldset")}
            service: @options.service

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