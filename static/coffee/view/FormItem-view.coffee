define [
  "jquery",
  "backbone",
  "underscore",
  "view/API-view"
],($,Backbone,_, APIView)-> 
  FormItemView = APIView.extend
    events:
      "click [data-js-close]" : "event_close"
      "click [data-js-options]" : "event_options"
      "click [data-js-inc-size]":"event_incSize"
      "click [data-js-dec-size]":"event_decSize"
      "mouseenter": "event_mouseenter"
      "mouseleave": "event_mouseleave"
    ###
    @param service
    @param type
    @param size
    ###
    initialize:->
      LOG "FormItemView","initialize"
      @$el.data DATA_VIEW, this
      @model.on "change", => @render()

    render:->
      templateHtml = @options.service.getTemplate @model.get("type")
      content = _.template templateHtml, @model.attributes
      html = @options.service.renderFormItemTemplate content
      @$el.html html
      @$el.find(".debug-show").html "row:#{@model.get('row')} position:#{@model.get('position')}"
      @updateSize()
      APIView::render.apply this, arguments

    remove:->
      LOG "FormItemView","remove"
      @model.destroy()
      Backbone.View.prototype.remove.apply this, arguments

    event_close:->
      @remove()

    cleanSize:($el)->
      $el.removeClass (item,className)->
        if /^span\d+/.test(className) then className else ""

    getSizeOfRow:->
      _.reduce @$el.parent().children(),((memo,el)=>
        memo + @getSizeFromClass $(el)
      ),0


    updateSize:->
      if @model.get("direction") is "vertical"
        oldSize = @getSizeFromClass @$el
        size = @model.get("size")
        freeSize = 12 - @getSizeOfRow()
        delta = size - oldSize
        if freeSize < delta and @model.set("size", oldSize + freeSize, {silent:true})
          size = @model.get("size")
      @cleanSize(@$el)
      if @model.get("direction") is "vertical"
        @$el.addClass "span#{size}"

    getSizeFromClass:($el)->
      clazz = $el.attr("class")
      res = /span(\d+)/.exec clazz
      if res and res.length >= 2 then parseInt(res[1]) else 0

    event_incSize:(e)->
      size = @model.get "size"
      @model.set "size", size + 1, validate:true

    event_decSize:(e)->
      size = @model.get "size"
      @model.set "size", size - 1, validate:true

    event_options:(e)->
      @options.service.showModal
        preRender: _.bind(@handle_preRender, this)
        postSave: _.bind(@handle_postSave, this)

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

    event_okPopover:(e)->
      data = _.reduce $(".popover input",@$el), ((memo,item)->
        memo[$(item).attr("name")] = $(item).val() and memo
      ),{}
      @model.set data
      @popover?.popover("hide")

    event_mouseenter:(e)->
      LOG "FormItemView", "event_mouseenter"
      $("[data-js-show-tools-item]",@$el).addClass("ui_settings-show")

    event_mouseleave:(e)->
      LOG "FormItemView", "event_mouseleave"
      $("[data-js-show-tools-item]",@$el).removeClass("ui_settings-show")

  FormItemView