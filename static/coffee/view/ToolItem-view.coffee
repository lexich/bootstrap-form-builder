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
        opts =
          connectToSortable:"[data-js-notvisual-drop]"
          scroll: false
      else
        opts =
          connectToSortable:"[data-drop-accept]:not([data-js-row-disable-drag]),[data-drop-accept-placeholder]"
      _.extend opts,
        appendTo:"body"
        opacity: 0.7
        cursor: "pointer"
        cursorAt:
          top: -1
          left: -1
        zIndex: 1000
        connectToSortable:"[data-drop-accept]:not([data-js-row-disable-drag]),[data-drop-accept-placeholder]"
        helper:"clone"
        start:_.bind(@handle_draggable_start, this)
        stop:_.bind(@handle_draggable_stop, this)

      @$el.draggable opts
      @template = _.template $("#{@templatePath}").html(), @options.data

    handle_draggable_start:->
      unless @notvisual
        $("[data-drop-accept-placeholder]")
          .not("[data-ghost-row]")
          .show()
      $("body").addClass("ui_draggableprocess")

    handle_draggable_stop:->
      unless @notvisual
        $("[data-drop-accept-placeholder]").hide()
      $("body").removeClass("ui_draggableprocess")

    render:-> 
      data = @options.service.getData(@options.type)
      @$el.html @template
      @$el.attr "data-#{DATA_TYPE}", @options.type
      @$el.addClass("ui_tools-#{@options.type}")
      data.$el.before @$el
      this
      
  ToolItemView