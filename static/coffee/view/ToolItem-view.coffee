define [
  "jquery",
  "backbone",
  "underscore",
  "view/FormItem-view"
  "model/FormItem-model"
  "jquery-ui/jquery.ui.draggable"
],($,Backbone,_,FormItemView, FormItemModel)->
  ToolItemView = Backbone.View.extend
    CONTAINER_SELECTOR:"[data-html-form]"
    placeholder:{}
    ###
    @param data    -  function which return {Object} for underscore template  
    ###
    initialize:->
      @$el.draggable
        appendTo:"body"
        clone:true
        opacity: 0.7
        cursor: "pointer"
        connectToSortable:"[data-drop-accept],[data-drop-accept-placeholder]"
        helper:_.bind( @handle_draggable_helper, this)
        start:_.bind(@handle_draggable_start, this)
        stop:_.bind(@handle_draggable_stop, this)

    handle_draggable_helper:->
      template = @options.service.getTemplate @options.type
      dataHolder = @options.service.getTemplateData(@options.type)
      _.template template, dataHolder

    handle_draggable_start:->
      $(@CONTAINER_SELECTOR).trigger("customdragstart")
      $("[data-drop-accept-placeholder]").show()

    handle_draggable_stop:->
      $(@CONTAINER_SELECTOR).trigger("customdragstop")
      $("[data-drop-accept-placeholder]").hide()

    render:-> 
      data = @options.service.getData(@options.type)
      @$el.html @options.template
      @$el.attr "data-#{DATA_TYPE}", @options.type
      @$el.addClass("ui_tools-#{@options.type}")
      data.$el.before @$el
      this
      
  ToolItemView