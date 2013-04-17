define [
  "jquery",
  "backbone",
  "underscore",
  "view/FormItem-view"
  "model/FormItem-model"
  "draggable"
],($,Backbone,_,FormItemView, FormItemModel)->
  ToolItemView = Backbone.View.extend
    templatePath:"#ToolItemViewTemplate"
    template:""
    placeholder:{}
    notvisual:false
    ###
    @param data    -  function which return {Object} for underscore template
    ###
    initialize:->
      @notvisual = @options.data.data.notvisual?
      if @notvisual
        connectToSortable="[data-js-notvisual-drop]"
      else
        connectToSortable="[data-drop-accept]:not([data-js-row-disable-drag]),[data-drop-accept-placeholder]"
      @$el.draggable
        appendTo:"body"
        clone:true
        opacity: 0.7
        cursor: "pointer"
        connectToSortable:connectToSortable
        helper:"clone"
        start:_.bind(@handle_draggable_start, this)
        stop:_.bind(@handle_draggable_stop, this)
      @template = _.template $("#{@templatePath}").html(), @options.data

    handle_draggable_start:->
      unless @notvisual
        $("[data-drop-accept-placeholder]").show()

    handle_draggable_stop:->
      unless @notvisual
        $("[data-drop-accept-placeholder]").hide()

    render:-> 
      data = @options.service.getData(@options.type)
      @$el.html @template
      @$el.attr "data-#{DATA_TYPE}", @options.type
      @$el.addClass("ui_tools-#{@options.type}")
      data.$el.before @$el
      this
      
  ToolItemView