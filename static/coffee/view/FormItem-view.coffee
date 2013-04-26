define [
  "jquery",
  "backbone",
  "underscore",
  "common/Log"
  "common/BackboneCustomView",
  "common/BackboneWireMixin"
],($,Backbone,_, Log)->

  log = Log.getLogger("view/FormItemView")

  CustomView = do(
    log = log
    __super__ = Backbone.CustomView
  )-> __super__.extend
    templatePath:"#FormItemViewTemplate"
    viewname:"formitem"

    itemsSelectors:
      controls:".controls"
      input:"input,select,textarea"
      moveElement:".ui_formitem__move"

    updateViewModes:->
      __super__::updateViewModes.apply this, arguments
      bVertical = @model.get("direction") is "vertical"
      size = @model.get("size")
      if !bVertical and size > @HORIZONTAL_SIZE_LIMIT
        @model.set "size", @HORIZONTAL_SIZE_LIMIT, {validate:true,silent:true}
        size = @model.get "size"

      $item = @getItem("input")

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

    templateData:->
      templateHtml = @options.service.getTemplate @model.get("type")
      data = _.extend id:_.uniqueId("tmpl_"), @model.attributes
      content = _.template templateHtml, data
      {content, model:@model.attributes, cid:@cid}

  FormItemView = do(
    __super__ = CustomView.extend Backbone.WireMixin,
    log = log
  )-> __super__.extend

    SELECTED_CLASS: "ui_formitem__editablemode"
    HORIZONTAL_SIZE_LIMIT: 12

    className:"ui_formitem"
    events:
      "click [data-js-formitem-decsize]":"event_decsize"
      "click [data-js-formitem-incsize]":"event_incsize"
      "click [data-js-formitem-remove]":"event_remove"
      "click":  "event_clickEditable"

    wireEvents:
      "editableView:change":"on_editableView_change"
      "editableView:remove":"on_editableView_remove"

    initialize:->
      log.info "initialize #{@cid}"
      @$el.data DATA_VIEW, this
      @listenTo @model, "change", @on_model_change

    remove:->
      log.info "remove #{@cid}"
      @unbindWireEvents()
      __super__::remove.apply this, arguments

    ###
    handler receive after change this.model
    ###
    on_model_change:->
      log.info "on_model_change #{@cid}"
      @render()

    ###
    editable view change, this view ,must be disconnected
    @param view - new view
    ###
    on_editableView_change:(view)->
      log.info "on_editableView_change #{@cid}"
      return if view is this
      @unbindWireEvents()
      @$el.removeClass(@SELECTED_CLASS)
      @parentView?.setSelected?(false)

    ###
    editableView must be remove
    ###
    on_editableView_remove:->
      log.info "on_editableView_remove #{@cid}"
      @remove()

    ###############
    # Events
    ###############

    ###
    Decrement control size
    ###
    event_decsize:->
      log.info "event_decsize #{@cid}"
      size = @model.get "size"
      if size > 2
        @model.set "size", size - 1, validate: true
    ###
    Increment control size
    ###
    event_incsize:->
      log.info "event_incsize #{@cid}"
      rowSize = @parentView.getCurrentRowSize()
      size = @model.get "size"
      return if @model.get("direction") == "horizontal" and rowSize > @HORIZONTAL_SIZE_LIMIT
      if rowSize < 12
        @model.set "size", size+1, {validate:true}

    ###
    Remove current item
    ###
    event_remove:->
      log.info "event_remove #{@cid}"
      @remove()

    ###
    set Editable mode to current view
    @param e - {Event}
    ###
    event_clickEditable:(e)->
      log.info "event_clickEditable #{@cid}"
      return if $(e.target).hasClass("ui_formitem__tools") or $(e.target).parents(".ui_formitem__tools").length > 0
      if @options.service.setEditableView(this)
        @bindWireEvents @options.service, @wireEvents
        @$el.addClass(@SELECTED_CLASS)
        @parentView?.setSelected?(true)


  FormItemView