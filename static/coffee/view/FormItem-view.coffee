define [
  "jquery",
  "backbone",
  "underscore",
  "view/API-view"
  "common/Log"
],($,Backbone,_, APIView, Log)->
  log = Log.getLogger("view/FormItemView")

  FormItemView = APIView.extend
    ###
    Constants
    ###
    SELECTED_CLASS: "ui_formitem__editablemode"
    HORIZONTAL_SIZE_LIMIT: 9

    ###
    Variables Backbone.CustomView
    ###
    templatePath:"#FormItemViewTemplate"
    viewname:"formitem"
    ###
    Variables Backbone.CustomView
    ###
    className:"ui_formitem"
    events:
      "click [data-js-formitem-decsize]":"event_decsize"
      "click [data-js-formitem-incsize]":"event_incsize"
      "click [data-js-formitem-remove]":"event_remove"
      "click":  "event_clickEditable"

    wireEvents:
      "editableView:change":"on_editableView_change"
      "editableView:remove":"on_editableView_remove"

    itemsSelectors:
      controls:".controls"
      input:"input,select,textarea"
      moveElement:".ui_formitem__move"

    ###
    @overwrite Backbone.View
    ###
    initialize:->
      log.info "initialize #{@cid}"
      @$el.data DATA_VIEW, this
      @model.on "change", _.bind(@on_model_change,this)

    bindWireEvents:->
      @__saveWireEvents = _.reduce @wireEvents or {}, ((save, callback,action)=>
        handler = _.bind(this[callback], this)
        @options.service.eventWire.on action, handler
        save[action] = handler
        save),{}

    unbindWireEvents:->
      _.each @__saveWireEvents or {}, (handler, action)=>
        @options.service.eventWire.off action, handler


    on_editableView_change:(view)->
      return if view is this
      @unbindWireEvents()
      @$el.removeClass(@SELECTED_CLASS)
      @parentView?.setSelected?(false)

    on_editableView_remove:->
      @unbindWireEvents()
      @remove()

    ###
    handler receive after change this.model
    ###
    on_model_change:(model,option)->
      log.info "on_model_change #{@cid}"
      @render()

    updateViewModes:->
      APIView::updateViewModes.apply this, arguments
      bVertical = @model.get("direction") is "vertical"
      size = @model.get("size")
      if !bVertical and size > @HORIZONTAL_SIZE_LIMIT
        @model.set "size", @HORIZONTAL_SIZE_LIMIT, {validate:true,silent:true}
        size = @model.get "size"

      $item = @getItem("input")
      @getItem("controls").addClass("row-fluid")

      @cleanSpan(@$el)
      @cleanSpan($item)
      if bVertical
        @$el.addClass("span#{size}")
        $item.addClass("span12")
      else
        $item.addClass("span#{@model.get('size')}")

      $move = @getItem("moveElement")
      if @model.get("direction") is "vertical"
        $move.removeAttr("data-js-row-move").attr("data-js-formitem-move","")
      else
        $move.removeAttr("data-js-formitem-move").attr("data-js-row-move","")

    ###
    @overwrite Backbone.CustomView
    ###
    templateData:->
      templateHtml = @options.service.getTemplate @model.get("type")
      data = _.extend id:_.uniqueId("tmpl_"), @model.attributes
      content = _.template templateHtml, data
      {content, model:@model.attributes, cid:@cid}

    ###############
    # Events
    ###############

    ###
    @event
    ###
    event_decsize:(e)->
      size = @model.get "size"
      if size > 1
        @model.set "size", size - 1, validate: true

    ###
    @event
    ###
    event_incsize:(e)->
      log.info "event_incsize #{@cid}"
      rowSize = @parentView.getCurrentRowSize()
      size = @model.get "size"
      return if @model.get("direction") == "horizontal" and rowSize > @HORIZONTAL_SIZE_LIMIT
      if rowSize < 12
        @model.set "size", size+1, {validate:true}
      else
        for item in [@parentView.getPrevious(this), @parentView.getNext(this)]
          if not (model = item?.model)
            continue
          itemSize = model.get("size")
          if itemSize > 1 and model.set "size", itemSize - 1, {validate:true}
            @model.set "size", size + 1, {validate:true}
            break

    event_remove:->
      log.info "event_remove #{@cid}"
      @remove()

    event_clickEditable:(e)->
      return if $(e.target).hasClass("ui_formitem__tools") and $(e.target).parents(".ui_formitem__tools").length > 0
      log.info "event_clickEditable"
      if @options.service.setEditableView(this)
        @bindWireEvents()
        @$el.addClass(@SELECTED_CLASS)
        @parentView?.setSelected?(true)

    #*****************************************************************************************#
    #                                                                                         #
    #                                                                                         #
    #*****************************************************************************************#

    getSizeFromClass:($el)->
      log.info "getSizeFromClass #{@cid}"
      clazz = $el.attr("class")
      res = /span(\d+)/.exec clazz
      if res and res.length >= 2 then parseInt(res[1]) else 1

    getSizeOfRow:->
      log.info "getSizeOfRow"
      _.reduce @$el.parent().children(),((memo,el)=>
        memo + @getSizeFromClass $(el)
      ),0

  FormItemView