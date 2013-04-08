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

    ###
    Variables Backbone.View
    ###
    events:
      "click [data-js-row-disable]":"event_disable"
      "click [data-js-row-position]":"event_direction"


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

    on_child_model_change_size__handler:->

    ###
    @overwrite Backbone.View
    ###
    initialize:->
      @model.on "change", _.bind(@on_model_change,this)
      @on_child_model_change_size__handler = _.bind(@on_child_model_change_size,this)

    ###
    @overwrite Backbone.CustomView
    ###
    templateData:->
      _.extend @model.toJSON(),cid:@cid

    ###
    @overwrite Backbone.View
    ###
    render:->
      log.info "render #{@cid}"
      if(sortable = @getItem("area").data("sortable"))
        sortable.destroy()

      Backbone.CustomView::render.apply this, arguments

      if _.isUndefined(@getItem("area").data("sortable"))
        connectWith = "[data-drop-accept]:not([#{@DISABLE_DRAG}]),[data-drop-accept-placeholder]"
        @getItem("area").sortable
          helper:"original"
          tolerance:"pointer"
          handle:"[data-js-formitem-move]"
          dropOnEmpty:"true"
          placeholder: "ui_formitem__placeholder"
          connectWith: connectWith
          start:_.bind(@handle_sortable_start, this)
          stop: _.bind(@handle_sortable_stop, this)
          update: _.bind(@handle_sortable_update,this)
      else
        @getItem("area").sortable("refresh")

      bVertical = @model.get('direction') == "vertical"
      @setVertical bVertical
      @updateDisableDrag()
      @updateSortablePlaceholder()

    ###
    Change current row (not) dragging depends of view's state
    ###
    updateDisableDrag:->
      $area = @getItem("area")
      if @model.get('direction') == "vertical"
        freeSize = 12 - @getCurrentRowSize()
        if freeSize <= 0
          $area.attr(@DISABLE_DRAG,"")
        else
          $area.removeAttr(@DISABLE_DRAG)
      else
        $area.removeAttr(@DISABLE_DRAG)

    ###
    Change placeholder view depenfs of view's state
    ###
    updateSortablePlaceholder:->
      log.info "updateSortablePlaceholder #{@cid}"
      placeholderClass = "ui_formitem__placeholder"
      if @model.get("direction") == "vertical"
        freeSize = 12 - @getCurrentRowSize()
        size = if freeSize > 2 then 3 else freeSize
        placeholderClass += " span#{size}"
      else
        placeholderClass += " row-fluid"
      @getItem("area").sortable("option","placeholder",placeholderClass)

    on_child_model_change_size:->
      @updateSortablePlaceholder()

    addChild:(view)->
      result = Backbone.CustomView::addChild.apply this, arguments
      view.model.on "change:size", @on_child_model_change_size__handler
      result

    removeChild:(view)->
      result = Backbone.CustomView::removeChild.apply this, arguments
      view.model.off "change:size", @on_child_model_change_size__handler
      result

    on_model_change:(model,options)->
      log.info "on_model_change #{@cid}"
      changed = _.pick model.changed, _.keys(model.defaults)
      if changed.direction?
        @setVertical changed.direction is "vertical"

      _.each @childrenViews,(view,cid)->
        #silent mode freeze changing beause render call
        view.model.set changed,{validate:true}


    event_disable:(e)->
      log.info "event_disable #{@cid}"
      @_disable = false unless @_disable?
      @_disable = !@_disable
      $(e.target).text if @_disable then "Disabled" else "Enabled"
      @setDisable @_disable

    event_direction:(e)->
      log.info "event_direction #{@cid}"
      value = if @model.get('direction') == 'vertical' then "horizontal" else "vertical"
      @model.set "direction", value,{validate:true}


    setVertical:(flag)->
      log.info "setVertical #{@cid}"
      if flag
        @$el.removeClass "form-horizontal"
      else
        @$el.addClass "form-horizontal"

    setDisable:(flag)->
      log.info "setDisable #{@cid}"
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
      log.info "reinitialize #{@cid}"
      models = @collection.getRow @model.get("fieldset"), @model.get("row")
      _.each models, (model)=>
        view = @getOrAddChildTypeByModel(model)
        view.reinitialize()

    getCurrentFreeRowSize:-> 12 - @getCurrentRowSize()

    handle_create_new:(event,ui)->
      log.info "handle_create_new #{@cid}"
      view = Backbone.CustomView::staticViewFromEl(ui.item)
      size = @getCurrentFreeRowSize()
      if view? and view.viewname is "formitem"
        position = _.size(@childrenViews)
        data = fieldset:@model.get('fieldset')
          row: @model.get('row')
          position:position
        if size < 3 then data.size = size
        @addChild view
        view.model.set data, {validate:true}
      else
        componentType = $(ui.item).data("componentType")
        data = @options.service.getTemplateData(componentType)
        if size < 3 then data.size = size
        view = @createChild
          model: @createFormItemModel(data)
          service: @options.service
      this

    ###
    Handle to jQuery.UI.sortable - update
    ###
    handle_sortable_update:(event,ui)->
      log.info "handle_sortable_update #{@cid}"
      formItemView = Backbone.CustomView::staticViewFromEl(ui.item)
      if ui.sender?
        log.info "handle_sortable_update #{@cid} ui.sender != null"
        #Если View найден, создаем дочерний
        if formItemView?
          parentView = formItemView.parentView
          #Если произошло перемещение между RowView, устанавливаем текуший
          if parentView != this
            formItemView.setParent this
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

    ###
    create new model FormItemModel
    @return FormItemModel
    ###
    createFormItemModel:(data)->
      log.info "createFormItemModel #{@cid}"
      data = _.extend data or {}, {row:@model.get("row"), fieldset:@model.get("fieldset")}
      model = new FormItemModel data
      @collection.add model
      model

    ###
    reindex all items in current row
    ###
    reindex:->
      log.info "reindex #{@cid}"
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
    childrenConnect:(self,view)->
      log.info "childrenConnect #{@cid}"
      view.$el.appendTo self?.getItem("area")

    getCurrentRowSize:->
      _.reduce @childrenViews, ((asize,view)->
        view.model.get("size") + asize
      ),0

    getOrAddChildTypeByModel:(model)->
      log.info "getOrAddChildTypeByModel #{@cid}"
      views = _.filter @childrenViews, (view, cid)-> view.model == model

      if views.length > 0 then view = views[0]
      else
        view = @createChild
          model: model
          service:@options.service
      view

    changeDirection:(model)->
      log.info "changeDirection #{@cid}"
      direction = model.get("direction")
      @$el.attr "data-direction", direction
      $area = @getItem("area")
      $children = $area.children()
      return unless $children.length > 0

      models = @collection.smartSliceNormalize @model.get("row"), "direction", direction
      _.each models,(model)=>
        model.set "direction",direction,{validate:true}

      if direction is DropAreaModel::VERTICAL
        @$el.removeClass("form-horizontal")
        $area.addClass("row-fluid")
      else if direction is DropAreaModel::HORIZONTAL
        @$el.addClass("form-horizontal")
        $area.removeClass("row-fluid")

    bindSettings:(holder)->
      log.info "bindSettings #{@cid}"
      @options.service.bindSettingsContainer
        holder: holder
        data: @model.toJSON()
        changePosition:   (val)=> @setDirection val
        hideContainer:    => @$el.removeClass @HOVER_CLASS
        saveContainer:
          (data)=> @model.set data, {validate:true}


    setDirection:(direction)->
      log.info "setDirection #{@cid}"
      @model.set "direction", direction, {validate:true}



  RowView