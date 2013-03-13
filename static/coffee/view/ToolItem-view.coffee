define [
  "jquery",
  "backbone",
  "underscore",
  "jquery-ui/jquery.ui.draggable"
],($,Backbone,_)-> 
  ToolItemView = Backbone.View.extend
    ###
    @param data    -  function which return {Object} for underscore template  
    ###
    initialize:->
      @$el.draggable
        appendTo:"body"
        clone:true
        opacity: 0.7
        connectToSortable:"[data-drop-accept]"
        helper:_.bind( @handle_draggable_helper, this)
        cursor: "pointer"

    handle_draggable_helper:(event)->
      $el = $(event.target)
      templateHtml = @options.service.getTemplate @options.type
      data = @options.service.getTemplateData(@options.type)
      _.template templateHtml, data

    render:-> 
      data = @options.service.getData(@options.type)
      @$el.html @options.template
      @$el.attr "data-#{DATA_TYPE}", @options.type
      @$el.addClass("ui_tools-#{@options.type}")
      data.$el.before @$el
      this
      
  ToolItemView