define [
  "jquery",
  "backbone",
  "underscore",
  "view/API-view"
],($,Backbone,_, APIView)-> 
  FormItemView = APIView.extend
    HOVER_CLASS: "hover"

    events:
      "click [data-js-min-size]":"event_Min"
      "mouseenter": "event_mouseenter"
      "mouseleave": "event_mouseleave"
      "click":  "event_click"
    ###
    @param service
    @param type
    @param size
    ###
    initialize:->
      LOG "FormItemView","initialize"
      @$el.data DATA_VIEW, this
      @model.on "change", => @render()
      @bindEvents()

    bindEvents: ->
      LOG "FormItemView","bindEvents"
      @events["click [data-js-right-size]"] = => @handle_Inc (=>@$el.next()), 1
      @events["click [data-js-left-size]"] =  => @handle_Inc (=>@$el.prev()), 1

    render:->
      LOG "FormItemView","render"
      templateHtml = @options.service.getTemplate @model.get("type")
      data = _.extend id:@options.service.nextID(), @model.attributes
      content = _.template templateHtml, data
      html = @options.service.renderFormItemTemplate content
      @$el.html html
      @updateSize()
      APIView::render.apply this, arguments

    remove:->
      LOG "FormItemView","remove"
      @model.destroy()
      Backbone.View.prototype.remove.apply this, arguments

    getSizeFromClass:($el)->
      LOG "FormItemView","getSizeFromClass"
      clazz = $el.attr("class")
      res = /span(\d+)/.exec clazz
      if res and res.length >= 2 then parseInt(res[1]) else 1

    getSizeOfRow:->
      LOG "FormItemView","getSizeOfRow"
      _.reduce @$el.parent().children(),((memo,el)=>
        memo + @getSizeFromClass $(el)
      ),0

    updateSize:->
      size = @model.get("size")
      @$el.removeClass (item,className)->
        if /^span\d+/.test(className) then className else ""
      if @model.get("direction") is "vertical"
        @$el.addClass "span#{size}"

    reduceNElement:($item, move)->
      view = $item.data DATA_VIEW
      size = view.model.get "size"
      if 1 < size > move and view.model.set("size", size - move, validate:true) then move
      else if size > 0 and view.model.set("size", 1, validate: true)            then size - 1
      else                                                                      0

    ###############
    # Events
    ###############

    event_Min:(e)->
      size = @model.get "size"
      if size > 1
        @model.set "size", size - 1, validate: true


    event_okPopover:(e)->
      data = _.reduce $(".popover input",@$el), ((memo,item)->
        memo[$(item).attr("name")] = $(item).val() and memo
      ),{}
      @model.set data
      @popover?.popover("hide")


    showSettings:(holder)->
      bShow = @options.service.showSettings
        preRender: _.bind(@handle_preRender, this)
        postSave: _.bind(@handle_postSave, this)
        remove: => @remove()
        holder: holder
        hide: => @$el.removeClass @HOVER_CLASS
      if bShow then @$el.addClass @HOVER_CLASS

    hideSettings:->
      if @options.service.hideSettings()
        @$el.removeClass @HOVER_CLASS

    event_click:(e)->
      @showSettings(true)

    event_mouseenter:(e)->
      @showSettings(null)

    event_mouseleave:(e)->
      @hideSettings()

    ###############
    # handlers
    ###############

    handle_Inc:(get$item, move)->
      size = @model.get "size"
      return unless 1 <= size + move <= 12
      freeSpace = 12 - @getSizeOfRow()
      if freeSpace >= move or (move = @reduceNElement get$item(), move)
        @model.set "size", size + move, validate:true

    handle_preRender:($el, $body)->
      type = @model.get("type")
      data = @model.attributes
      $item = @options.service.renderModalForm(type, data)
      if $item.length is 1
        $body.empty()
        $item.appendTo $body
        $item.show()
      else 
        meta = @options.service.getTemplateMetaData(type)
        service = @options.service
        content = _.map data, (v,k)->
          itemType = meta[k] or ""
          service.renderModalItemTemplate itemType,
            name: k
            value: v
            data: service.getItemFormTypes()
        $body.html content.join("")
    
    handle_postSave:($el,$body)->
      data = @options.service.parceModalItemData $body
      @model.set data


  FormItemView