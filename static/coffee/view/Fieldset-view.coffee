define [
  "jquery"
  "backbone"
  "underscore"
  "view/Row-view"
  "model/Row-model"
  "common/Log"
  "common/BackboneCustomView"
  "sortable"
],($,Backbone,_,RowView,RowModel,Log)->
  log = Log.getLogger("view/FieldsetView")

  FieldsetView = Backbone.CustomView.extend
    ###
    Variables Backbone.View
    ###
    viewname:"fieldset"
    tagName:"fieldset"
    events:
      "click [data-js-remove-fieldset]": "event_remove"
      "input [contenteditable][data-bind]":"event_inputDataBind"
      "click [data-js-fieldset-position]":"event_clickDirection"

    event_clickDirection:->
      bVertical = @model.get('direction') == 'vertical'
      value = if bVertical then "horizontal" else "vertical"
      @model.set "direction", value, {validate:true}
      @checkModel log, @model


    event_inputDataBind:(e)->
      @model.set "title", $(e.target).text(), {validate:true, silent:true}
      @checkModel log, @model

    ###
    Variables Backbone.CustomView
    ###
    ChildType: RowView
    templatePath:"#FieldsetViewTemplate"
    placeholderSelector:"[data-drop-accept-placeholder='form']"
    itemsSelectors:
      loader:"[data-html-fieldset-loader]"
      loaderChildren:"[data-html-fieldset-loader] >"
      direction:"[data-js-fieldset-position]"

    ###
    @overwrite Backbone.View
    ###
    initialize:->
      log.info "initialize #{@cid}"
      @bindEvents()
      @model.on "change", _.bind(@on_model_change,this)

    on_model_change:(model,options)->
      log.info "on_model_change #{@cid}"
      changed = _.pick model.changed, _.keys(model.defaults)
      if changed.direction?
        _.each @childrenViews,(view)=>
          view.model.set "direction", changed.direction,{validate:true}
          @checkModel log, view.model
      _.each @childrenViews,(view,cid)->
        #silent mode freeze changing beause render call
        view.model.set changed,{validate:true}
      @render()

    ###
    @overwrite Custom.View
    ###
    updateViewModes:->
      log.info "updateViewModes #{@cid}"
      if (sortable = @getItem("loader").data("sortable"))
        sortable.destroy()
      Backbone.CustomView::updateViewModes.apply this, arguments
      connector = "[data-html-fieldset-loader]:not([data-js-row-disable-drag]),[data-drop-accept-placeholder='form']"
      @getItem("loader").sortable
        helper:"original"
        handle:"[data-js-row-move]"
        tolerance:"pointer"
        dropOnEmpty:true
        placeholder:"ui_row__placeholder"
        connectWith: connector
        start:_.bind(@handle_sortable_start, this)
        stop: _.bind(@handle_sortable_stop, this)
        update: _.bind(@handle_sortable_update,this)

      if @model.get("direction") is "vertical"
        @getItem("direction").addClass("icon-resize-horizontal").removeClass("icon-resize-vertical")
        @$el.find(".ui_global_placeholder").not('.ui_row__prev_loader').removeClass("form-horizontal")
      else
        @getItem("direction").addClass("icon-resize-vertical").removeClass("icon-resize-horizontal")
        @$el.find(".ui_global_placeholder").not('.ui_row__prev_loader').addClass("form-horizontal")

      this

    ###
    @overwrite Backbone.CustomView
    ###
    reindex:->
      log.info "reindex #{@cid}"
      _.reduce @getItem("loaderChildren"), ((row,el)=>
        if(view = Backbone.CustomView::staticViewFromEl el)
          view.model?.set {
            row: row
            fieldset: @model.get "fieldset"
          }, {validate: true}
        row + 1
      ),0

    ###
    @overwrite Backbone.CustomView
    ###
    handle_create_new:(event,ui)->
      log.info "handle_create_new #{@cid}"
      view = Backbone.CustomView::staticViewFromEl(ui.item)
      row = _.size(@childrenViews)
      if view? and view.viewname is "row"
        @addChild view
        view.model.set
          fieldset:@model.get("fieldset")
          row:row,
          {validate:true}
      else
        view = @getOrAddRowView row
        view.handle_create_new(event,ui).reindex()
      this

    ###
    Handle to jQuery.UI.sortable - update
    ###
    handle_sortable_update:(event,ui)->
      log.info "handle_sortable_update #{@cid}"
      rowView = Backbone.CustomView::staticViewFromEl(ui.item)
      if ui.sender?
        log.info "handle_sortable_update #{@cid} ui.sender != null"
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
            model: new RowModel {fieldset:@model.get("fieldset"), direction:@model.get("direction")}
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
      log.info "reinitialize #{@cid}"
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

    insertRow:(row) ->
      log.info "insertRowView #{@cid}"
      filterRowView = _.chain(@childrenViews)
        .filter (view)->
          view.model.get("row") >= row
        .map (view)->
          view.model.set "row", view.model.get("row")+1, {validate:true, silent:true}
          view
        .value()
      @getOrAddRowView row

    getOrAddRowView:(row)->
      log.info "getOrAddRowView #{@cid}"
      filterRowView = _.filter @childrenViews, (view)->
        view.model.get("row") == row

      if filterRowView.length > 0
        view = filterRowView[0]
      else
        model = @collection.getOrAddRowModel row, @model.get("fieldset")
        model.set "direction", @model.get("direction"), {validation:true}
        view = @createChild
          collection:@collection
          model:model
          service: @options.service
      view

    bindEvents:->
      #bind events

    childrenConnect:(self,view)->
      self.getItem("loader").append view.$el

    event_remove:(e)->
      @destroy()

  FieldsetView