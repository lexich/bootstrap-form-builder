define [
  "jquery"
  "backbone"
  "underscore"
  "view/FormItem-view"
  "model/FormItem-model"
  "model/DropArea-model"
  "common/Log"
  "jquery-ui/jquery.ui.draggable"
  "jquery-ui/jquery.ui.droppable"
  "jquery-ui/jquery.ui.sortable"
  "common/BackboneCustomView"
],($,Backbone,_,FormItemView,FormItemModel, DropAreaModel, Log)->
  log = Log.getLogger("view/RowView")

  RowView = Backbone.CustomView.extend
    ###
    Constants
    ###
    HOVER_CLASS: "hover-container"
    DISABLE_DRAG: "data-js-row-disable-drag"
    handlers:{}

    ###
    Variables Backbone.View
    ###
    events:
      "click [data-js-row-disable]":"event_disable"
      "click [data-js-row-position]":"event_direction"
      "click [data-js-row-remove]": "event_remove"


    className:"ui_row"

    ###
    Variables Backbone.CustomView
    ###
    viewname:"row"
    templatePath:"#RowViewTemplate"
    ChildType:FormItemView
    itemsSelectorsCache:false
    itemsSelectors:
      area:"[data-drop-accept]"
      areaChildren:"[data-drop-accept] >"
      placeholderItem:".ui_formitem__placeholder"
      directionMode:"[data-js-row-position]"

    ###
    @overwrite Backbone.View
    ###
    initialize:->
      @model.on "change", _.bind(@on_model_change,this)
      @handlers['on_child_model_changes_size'] = _.bind(@on_child_model_changes_size,this)

    ###
    @overwrite Backbone.CustomView
    ###
    templateData:->
      _.extend @model.toJSON(),cid:@cid

    ###
    Update view modes depends models
    ###
    updateViewModes:->
      log.info "updateViewModes #{@viewname}:#{@cid}"
      Backbone.CustomView::updateViewModes.apply this, arguments
      $area = @getItem("area")
      @updateViewModes__direction()
      connectWith = "[data-drop-accept]:not([#{@DISABLE_DRAG}]),[data-drop-accept-placeholder]"
      if(sortable = $area.data("sortable"))
        sortable.destroy()

      $area.sortable
        helper:"original"
        tolerance:"pointer"
        handle:"[data-js-formitem-move]"
        dropOnEmpty:"true"
        placeholder: "ui_formitem__placeholder"
        connectWith: connectWith
        start:_.bind(@handle_sortable_start, this)
        stop: _.bind(@handle_sortable_stop, this)
        update: _.bind(@handle_sortable_update,this)

    updateViewModes__direction:->
      log.info "updateViewModes__direction #{@viewname}:#{@cid}"
      Backbone.CustomView::updateViewModes.apply this, arguments
      bVertical = @model.get('direction') is "vertical"

      $el = @getItem("directionMode")
      #direction mode check
      if bVertical
        @$el.removeClass "form-horizontal"
        $el.addClass("icon-resize-horizontal").removeClass("icon-resize-vertical")
        if _.size(@childrenViews) > 1
          $el.addClass("hide")
        else
          $el.removeClass("hide")
      else
        @$el.addClass "form-horizontal"
        $el.addClass("icon-resize-vertical").removeClass("icon-resize-horizontal")

      #disable mode
      bDisable = false
      if bVertical
        freeSize = @getCurrentFreeRowSize()
        if freeSize <= 0 then bDisable = true
      else
        bDisable = true
      @setDisable bDisable

    setDisable:(flag)->
      log.info "setDisable #{@viewname}:#{@cid}"
      flag = true unless flag?
      $area = @getItem("area")
      if flag
        $area.attr(@DISABLE_DRAG,"")
      else
        $area.removeAttr(@DISABLE_DRAG)

    ###
    @overwrite Backbone.CustomView
    ###
    childrenViewsOrdered:->
      _.sortBy @childrenViews, (view,cid)-> view.model.get("position")

    ###
    Get child view by model value  position
    ###
    _getFormItemByPosition:(position)->
      result = _.filter @childrenViews, (view)->
        view.model.get("position") is position
      result[0] if result.length > 0

    ###
    @overwrite Backbone.CustomView
    ###
    getPrevious:(view)-> @_getFormItemByPosition view.model.get("position") - 1

    ###
    @overwrite Backbone.CustomView
    ###
    getNext:(view)-> @_getFormItemByPosition view.model.get("position") + 1


    ###
    @overwrite Backbone.CustomView
    ###
    reinitialize:->
      log.info "reinitialize #{@viewname}:#{@cid}"
      models = @collection.getRow @model.get("fieldset"), @model.get("row")
      _.each models, (model)=>
        view = @getOrAddChildTypeByModel(model)
        view.reinitialize()

    ###
    @overwrite Backbone.CustomView
    ###
    handle_create_new:(event,ui)->
      log.info "handle_create_new #{@viewname}:#{@cid}"
      view = Backbone.CustomView::staticViewFromEl(ui.item)
      size = @getCurrentFreeRowSize()
      if view? and view.viewname is "formitem"
        position = _.size(@childrenViews)
        data =
          fieldset:@model.get('fieldset')
          row: @model.get('row')
          position:position
        if size < 3 then data.size = size
        @addChild view
        view.model.set data, {validate:true}
        @checkModel(log,view.model)
      else
        componentType = $(ui.item).data("componentType")
        data = @options.service.getTemplateData(componentType)
        if size < 3 then data.size = size
        view = @createChild
          model: @createFormItemModel(data)
          service: @options.service
      this

    ###
    create new model FormItemModel
    @return FormItemModel
    ###
    createFormItemModel:(data)->
      log.info "createFormItemModel #{@viewname}:#{@cid}"
      data = _.extend data or {}, {row:@model.get("row"), fieldset:@model.get("fieldset")}
      model = new FormItemModel data
      @collection.add model
      model

    ###
    @overwrite Backbone.CustomView
    ###
    reindex:->
      log.info "reindex #{@viewname}:#{@cid}"
      _.reduce @getItem("areaChildren"), ((position,el)=>
        if(view = Backbone.CustomView::staticViewFromEl el)
          view.model?.set {
             position
             row: @model.get "row"
             fieldset: @model.get "fieldset"
             direction: @model.get "direction"
          }, { validate: true }

        position + 1
      ),0

    ###
    @overwrite Backbone.CustomView
    ###
    addChild:(view)->
      log.info "addChild #{@viewname}:#{@cid}"
      result = Backbone.CustomView::addChild.apply this, arguments
      if view.model
        view.model.set "direction", @model.get("direction"),{validate:true, silent:true}
        @checkModel(log,view.model)
        view.model?.on "change:size", @handlers['on_child_model_changes_size']
      result

    ###
    @overwrite Backbone.CustomView
    ###
    removeChild:(view)->
      log.info "removeChild #{@viewname}:#{@cid}"
      result = Backbone.CustomView::removeChild.apply this, arguments
      view?.model?.off "change:size", @handlers['on_child_model_changes_size']
      result

    ###
    @overwrite Backbone.CustomView
    ###
    childrenConnect:(self,view)->
      log.info "childrenConnect #{@viewname}:#{@cid}"
      view.$el.appendTo self?.getItem("area")

    getCurrentRowSize:->
      _.reduce @childrenViews, ((asize,view)->
        view.model.get("size") + asize
      ),0

    getCurrentFreeRowSize:-> 12 - @getCurrentRowSize()

    getOrAddChildTypeByModel:(model)->
      log.info "getOrAddChildTypeByModel #{@viewname}:#{@cid}"
      views = _.filter @childrenViews, (view, cid)-> view.model == model

      if views.length > 0 then view = views[0]
      else
        view = @createChild
          model: model
          service:@options.service
      view

    #****************************
    # Handlers
    #****************************
    ###
    Bind to child models on "change:size" event
    ###
    on_child_model_changes_size:(model,size)->
      log.info "on_child_model_changes_size #{@viewname}:#{@cid}"
      @updateViewModes__direction()

    ###
    Bind to current model on "change" event
    ###
    on_model_change:(model,options)->
      log.info "on_model_change #{@viewname}:#{@cid}"
      changed = _.pick model.changed, _.keys(model.defaults)

      if changed.direction
        @updateViewModes__direction()

      _.each @childrenViews,(view,cid)=>
        #silent mode freeze changing beause render call
        view.model.set changed,{validate:true}
        @checkModel(log,view.model)


    ###
    Handle to jQuery.UI.sortable - start
    ###
    handle_sortable_start:(event,ui)->
      Backbone.CustomView::handle_sortable_start.apply this, arguments
      if (view = Backbone.CustomView::staticViewFromEl(ui.item))
        size = view.model.get("size")
      else
        size = @getCurrentFreeRowSize()
        if size > 3 then size = 3
      $item = $(".ui_formitem__placeholder", @$el)
      @cleanSpan($item).addClass "span#{size}"

    ###
    Handle to jQuery.UI.sortable - update
    ###
    handle_sortable_update:(event,ui)->
      log.info "handle_sortable_update #{@viewname}:#{@cid}"
      formItemView = Backbone.CustomView::staticViewFromEl(ui.item)
      if ui.sender?
        log.info "handle_sortable_update #{@viewname}:#{@cid} ui.sender != null"
        #Если View найден, создаем дочерний
        if formItemView?
          parentView = formItemView.parentView
          #Если произошло перемещение между RowView, устанавливаем текуший
          if parentView != this
            @addChild formItemView
            @reindex()
      unless formItemView?
        componentType = $(ui.item).data("componentType")
        size = @getCurrentFreeRowSize()
        data = @options.service.getTemplateData(componentType)
        if size < 3 then data.size = size
        formItemView = @createChild
          model: @createFormItemModel(data)
          service: @options.service
        ui.item.replaceWith formItemView.$el
        @reindex()
        @render()


    #****************************
    # Events
    #****************************
    event_disable:(e)->
      log.info "event_disable #{@viewname}:#{@cid}"
      @_disable = false unless @_disable?
      @_disable = !@_disable
      $(e.target).text if @_disable then "Disabled" else "Enabled"
      @setDisable @_disable

    event_direction:(e)->
      log.info "event_direction #{@viewname}:#{@cid}"
      value = if @model.get('direction') == 'vertical' then "horizontal" else "vertical"
      @model.set "direction", value,{validate:true}
      @checkModel(log,@model)


    event_remove:->
      log.info "event_remove #{@viewname}:#{@cid}"
      @remove()


  RowView