define [
  "jquery"
  "backbone"
  "underscore"
  "view/FormItem-view"
  "model/FormItem-model"
  "common/Log"
  "sortable"
  "common/BackboneCustomView"
],($,Backbone,_,FormItemView,FormItemModel, Log)->

  RowViewCustomView = do(
    __super__ = Backbone.CustomView,
    log = Log.getLogger("view/RowViewCustomView")
  )-> __super__.extend

    viewname:"row"
    templatePath:"#RowViewTemplate"
    ChildType:FormItemView
    itemsSelectorsCache:false
    itemsSelectors:
      area:"[data-drop-accept]"
      areaChildren:"[data-drop-accept] >"
      placeholderItem:".ui_formitem__placeholder"
      directionMode:"[data-js-row-position]"
      ghostRow:"[data-ghost-row]"

    childrenViewsOrdered:->
      chain = _.chain(
        @childrenViews
      ).sortBy(
        (view,cid)-> view.model.get("position")
      )
      if @model.get("extention") is "multitypeinput"
        chain = chain.filter(
          (view)=> view.model.get("filter") is @model.get("filter")
        )
      chain.value()


    templateData:->
      _.extend @model.toJSON(),cid:@cid

    updateViewModes:->
      log.info "updateViewModes #{@viewname}:#{@cid}"
      __super__::updateViewModes.apply this, arguments
      $area = @getItem("area")
      bVertical = @model.get('direction') is "vertical"
      $el = @getItem("directionMode")
      #direction mode check
      if bVertical
        @$el.removeClass "form-horizontal"
        @getItem("ghostRow").removeClass("form-horizontal")
        $el.addClass("icon-resize-horizontal").removeClass("icon-resize-vertical")
        if _.size(@childrenViews) > 1
          $el.addClass("hide")
        else
          $el.removeClass("hide")
      else
        @$el.addClass "form-horizontal"
        @getItem("ghostRow").addClass("form-horizontal")
        $el.addClass("icon-resize-vertical").removeClass("icon-resize-horizontal")

      connectWith = "[data-drop-accept]:not([#{@DISABLE_DRAG}]),[data-drop-accept-placeholder]"

      $area.data("sortable")?.destroy()

      $area.sortable
        helper:"original"
        tolerance:"pointer"
        handle:"[data-js-formitem-move]"
        dropOnEmpty:true
        placeholder: "ui_formitem__placeholder"
        change:_.bind(@handle_sortable_change,this)
        connectWith: connectWith
        start:_.bind(@handle_sortable_start, this)
        stop: _.bind(@handle_sortable_stop, this)
        over: _.bind(@handle_sortable_over, this)
        update: _.bind(@handle_sortable_update,this)
        activate: _.bind(@handle_sortable_activate, this)
        deactivate: _.bind(@handle_sortable_deactivate, this)

      #disable mode
      bDisable = false
      if bVertical
        freeSize = @getCurrentFreeRowSize()
        if freeSize <= 1 then bDisable = true
      else
        bDisable = true
      @setDisable bDisable

    getPreviousRow:(view)-> @parentView.getRowByPosition view.model.get("row") - 1

    getNextRow:(view)-> @parentView.getRowByPosition view.model.get("row") + 1

    reinitialize:->
      log.info "reinitialize #{@viewname}:#{@cid}"
      models = @collection.getRow @model.get("fieldset"), @model.get("row")
      _.each models, (model)=>
        view = @getOrAddChildTypeByModel(model)
        view.reinitialize()

    handle_create_new:(event,ui)->
      log.info "handle_create_new #{@viewname}:#{@cid}"
      view = __super__::staticViewFromEl(ui.item)
      size = @getCurrentFreeRowSize()
      if view? and view.viewname is "formitem"
        if ui.item.parent().is('[data-ghost-row]')
          row = @parentView.insertRow @model.get "row"
          data =
            fieldset:row.model.get('fieldset')
            row: row.model.get('row')
            filter: @model.get("filter")
            position:0
          row.addChild view
          view.model.set data, {validate:true}
          @checkModel(log,view.model)
          row.parentView.render()
        else
          position = _.size(@childrenViews)
          data =
            fieldset:@model.get('fieldset')
            row: @model.get('row')
            filter: @model.get("filter")
            position:position
          if size < 3 then data.size = size
          @addChild view
          view.model.set data, {validate:true}
          @checkModel(log,view.model)
      else
        componentType = $(ui.item).data("componentType")
        data = @options.service.getTemplateData(componentType)
        if ui.item.parent().is('[data-ghost-row]')
          row = @parentView.insertRow @model.get "row"
          row.createChild
            model: row.createFormItemModel(data)
            service: row.options.service
            collection: row.collection
          row.parentView.render()
          ui.helper?.remove()
        else
          view = @createChild
            model: @createFormItemModel(data)
            service: @options.service
            collection:@collection
      this

    reindex:->
      log.info "reindex #{@viewname}:#{@cid}"
      _.reduce @getItem("areaChildren"), ((position,el)=>
        if(view = __super__::staticViewFromEl el)
          row = @model.get "row"
          fieldset = @model.get "fieldset"
          direction = @model.get "direction"
          view.model?.set {position, row, fieldset, direction}, {validate: true }
        position + 1
      ),0

    addChild:(view)->
      log.info "addChild #{@viewname}:#{@cid}"
      result = __super__::addChild.apply this, arguments
      if view.model
        view.model.set "direction", @model.get("direction"),{validate:true, silent:true}
        @checkModel(log,view.model)
        @listenTo view.model, "change:size", @on_child_model_changes_size
      @parentView.updateDirectionVisible()
      result

    removeChild:(view)->
      log.info "removeChild #{@viewname}:#{@cid}"
      result = __super__::removeChild.apply this, arguments
      @stopListening view?.model, "change:size", @on_child_model_changes_size
      result

    childrenConnect:(self,view)->
      log.info "childrenConnect #{@viewname}:#{@cid}"
      view.$el.appendTo self?.getItem("area")


  RowViewSortableHandlers = do (
    __super__ = RowViewCustomView,
    log = Log.getLogger("view/RowViewSortableHandlers")
  ) -> __super__.extend

    handle_sortable_change:(event,ui)->
      log.info "handle_sortable_change #{@cid}"
      freesize = @getCurrentFreeRowSize()
      size = 3
      if (view = __super__::staticViewFromEl(ui.item))
        size = view.model.get("size")
        unless view.parentView is this
          if size > freesize then size = freesize
      else
        if freesize <= 3 then size = freesize

      @cleanSpan(ui.placeholder).addClass "span#{size}"

    handle_sortable_over:(event,ui)->
      $("[data-ghost-row]")
        .hide()
      if not (@getPreviousRow(@)?.$el.is(@originParent) and _.size(@getPreviousRow(@).childrenViews) <= 1)
        if (not @$el.is(@originParent) or _.size(@childrenViews) > 1)
          @getItem("ghostRow")
            .show()
            .sortable "refreshPositions"
      true

    handle_sortable_deactivate:(event,ui)->
      @getItem("area").removeClass("ui_row__loader_active")
      @getItem("ghostRow").hide()
      @originParent = null

    handle_sortable_activate:(event,ui)->
      @originParent = ui.sender?.closest(".#{@className}")
      @getItem("area").addClass("ui_row__loader_active") unless @getItem("area").is("[#{@DISABLE_DRAG}]")

    handle_sortable_update:(event,ui)->
      log.info "handle_sortable_update #{@viewname}:#{@cid}"
      formItemView = __super__::staticViewFromEl(ui.item)
      if ui.sender?
        log.info "handle_sortable_update #{@viewname}:#{@cid} ui.sender != null"
        #Если View найден, создаем дочерний
        if formItemView?
          parentView = formItemView.parentView
          #Проверим влезает ли элемент по размеру
          if (model = formItemView.model)
            freesize = @getCurrentFreeRowSize()
            if model.get("size") > freesize
              model.set "size", freesize, {validate:true, silent:true}
              @checkModel log, model
          #Если произошло перемещение между RowView, устанавливаем текуший
          if parentView != this
            @addChild formItemView
            @reindex()
      unless formItemView?
        componentType = $(ui.item).data("componentType")
        freesize = @getCurrentFreeRowSize()
        data = @options.service.getTemplateData(componentType)
        if data.size > freesize then data.size = freesize
        formItemView = @createChild
          model: @createFormItemModel(data)
          collection:@collection
          service: @options.service
        ui.item.replaceWith formItemView.$el
        @reindex()
        @render()


  RowView = do (
    __super__ = RowViewSortableHandlers,
    log = Log.getLogger("view/RowView")
  )-> __super__.extend

    SELECTED_CLASS:"ui_row__selected"
    DISABLE_DRAG: "data-js-row-disable-drag"
    placeholderSelector:"[data-drop-accept-placeholder]:not([data-ghost-row])"

    ###
    Variables Backbone.View
    ###
    events:
      "click [data-js-row-disable]":"event_disable"
      "click [data-js-row-position]":"event_direction"
      "click [data-js-row-remove]": "event_remove"
      "mouseenter [data-drop-accept]": "event_mouseEnter"

    className:"ui_row"

    initialize:->
      @model.on "change", _.bind(@on_model_change,this)

    setSelected:(bValue)->
      if bValue
        @$el.addClass @SELECTED_CLASS
      else
        @$el.removeClass @SELECTED_CLASS

    setDisable:(flag)->
      log.info "setDisable #{@viewname}:#{@cid}"
      flag = true unless flag?
      $area = @getItem("area")
      if flag
        $area.attr(@DISABLE_DRAG,"")
      else
        $area.removeAttr(@DISABLE_DRAG)

    ###
    create new model FormItemModel
    @return FormItemModel
    ###
    createFormItemModel:(data)->
      log.info "createFormItemModel #{@viewname}:#{@cid}"
      freesize = @getCurrentFreeRowSize()
      data = _.extend data or {}, {
        row:@model.get("row")
        fieldset:@model.get("fieldset")
      }
      model = new FormItemModel data
      if model.get("size") > freesize
        model.set "size", freesize, {validate:true,silence:true}
      @collection.add model
      model

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
          collection:@collection
          service:@options.service
      view

    isVisibleDirection:-> _.size(@childrenViews) <= 1

    #****************************
    # Handlers
    #****************************
    ###
    Bind to child models on "change:size" event
    ###
    on_child_model_changes_size:(model,size)->
      log.info "on_child_model_changes_size #{@viewname}:#{@cid}"
      @updateViewModes()

    ###
    Bind to current model on "change" event
    ###
    on_model_change:(model,options)->
      log.info "on_model_change #{@viewname}:#{@cid}"
      changed = _.pick model.changed, _.keys(model.defaults)

      _.each @childrenViews,(view,cid)=>
        #silent mode freeze changing beause render call
        view.model.set changed,{validate:true}
        @checkModel(log,view.model)

      if changed.direction
        @updateViewModes()

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

    event_mouseEnter:->
      if @dragActive and @getItem("area").is("[#{@DISABLE_DRAG}]")
        $("[data-ghost-row]").hide()
        @getItem("ghostRow")
          .show()
          .sortable "refreshPositions"


  RowView