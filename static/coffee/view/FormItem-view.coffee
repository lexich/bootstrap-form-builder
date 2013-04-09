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
    HOVER_CLASS: "ui_formitem__editablemode"

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

    event_remove:->
      @remove()

    itemsSelectors:
      "controls":".controls"
      "input":"input,select,textarea"

    ###
    @overwrite Backbone.View
    ###
    initialize:->
      log.info "initialize #{@cid}"
      @$el.data DATA_VIEW, this
      @model.on "change", _.bind(@on_model_change,this)

    ###
    handler receive after change this.model
    ###
    on_model_change:(model,option)->
      log.info "on_model_change #{@cid}"
      changed = _.pick model.changed, _.keys(model.defaults)
      if changed.direction?
        @setVertical changed.direction is "vertical"
      @render()

    ###
    change position of row direction
    @param flag : true (vertical) false (horizontal)
    ###
    setVertical:(flag)->
      @$el.removeClass (name)->
        /span\d{1,2}$/.test name or /offset\d{1,2}/.test name

      $controls = @getItem("controls")
      $item = @getItem("input")
      if flag
        size = @model.get("size")
        @$el.addClass("span#{size}")
        $controls.addClass("row-fluid")
        $item.addClass("span12")
      else
        $controls.removeClass("row-fluid")
        $item.removeClass("span12")

    ###
    @overwrite Backbone.CustomView
    ###
    templateData:->
      templateHtml = @options.service.getTemplate @model.get("type")
      data = _.extend id:_.uniqueId("tmpl_"), @model.attributes
      content = _.template templateHtml, data
      {content, model:@model.attributes}

    ###
    @overwrite Backbone.View
    ###
    render:->
      log.info "render #{@cid}"
      APIView::render.apply this, arguments
      @updateSize()
      @setVertical @model.get("direction") is "vertical"

    ###
    Update component size
    ###
    updateSize:->
      clazz = @$el.attr("class").replace(/span\d{1,2}/g,"")
      if @model.get("direction") is "vertical"
        size = @model.get("size")
        clazz += " span#{size}"
      @$el.attr "class", clazz

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

    reduceNElement:($item, move)->
      view = $item.data DATA_VIEW
      size = view.model.get "size"
      if 1 < size > move and view.model.set("size", size - move, validate:true) then move
      else if size > 0 and view.model.set("size", 1, validate: true)            then size - 1
      else                                                                      0

    event_okPopover:(e)->
      data = _.reduce $(".popover input",@$el), ((memo,item)->
        memo[$(item).attr("name")] = $(item).val() and memo
      ),{}
      @model.set data
      @popover?.popover("hide")

    wireEvents:
      "editableModel:change":"on_editableModel_change"
      "editableModel:remove":"on_editableModel_remove"

    bindWireEvents:->
      @__saveWireEvents = _.reduce @wireEvents or {}, ((save, callback,action)=>
        handler = _.bind(this[callback], this)
        @options.service.eventWire.on action, handler
        save[action] = handler
        save),{}

    unbindWireEvents:->
      _.each @__saveWireEvents or {}, (handler, action)=>
        @options.service.eventWire.off action, handler


    on_editableModel_change:->
      @unbindWireEvents()
      @$el.removeClass(@HOVER_CLASS)

    on_editableModel_remove:->
      @unbindWireEvents()
      @remove()

    event_clickEditable:(e)->
      log.info "event_clickEditable"
      if @options.service.setEditableModel(@model)
        @bindWireEvents()
        @$el.addClass(@HOVER_CLASS)


  FormItemView