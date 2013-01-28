define [
  "jquery",
  "backbone",
  "underscore"
],($,Backbone,_)-> 
  FormItemView = Backbone.View.extend
    events:
      "click *[data-js-close]" : "event_close"
      "click *[data-js-options]" : "event_options"
    ###
    @param service
    @param type
    ###
    initialize:->
      LOG "FormItemView","initialize"
      @$el.data DATA_VIEW, this
      @model.on "change", => @render()
      @render()
    
    render:->
      templateHtml = @options.service.getTemplate @model.get("type")
      content = _.template templateHtml, @model.attributes
      html = @options.service.renderFormItemTemplate content
      @$el.html html
      @$el.find(".debug").html "row:#{@model.get('row')} position:#{@model.get('position')}"

    remove:->
      LOG "FormItemView","remove"
      @model.destroy()
      Backbone.View.prototype.remove.apply this, arguments

    event_close:->
      @remove()

    event_options:(e)->
      @options.service.showModal
        preRender: _.bind(@handle_preRender, this)
        postSave: _.bind(@handle_postSave, this)

    handle_preRender:($el, $body)->
      type = @model.get("type")
      meta = @options.service.getTemplateMetaData(type)
      data = @model.attributes
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
  FormItemView