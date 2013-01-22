RenderView = Backbone.View.extend
  DATA_TEMPLATE: "ui-jsrender-template"
  DATA_DATA: "ui-jsrender-data"
  ###
  @param data    -  function which return {Object} for underscore template  
  ###
  initialize: (options)->
    @templateData = -> options.data()    
    @htmlWrapper = (content)-> options.wrapper(content)
    @render()

  render:-> 
    content = _.template @templateHTML(), @templateData()    
    $newEl = $ @htmlWrapper(content)
    $newEl.data @DATA_TEMPLATE, @templateHTML()
    $newEl.data @DATA_DATA, @templateData()
    @$el.after $newEl

  templateHTML:->@el.innerHTML.trim()

  templateData:->{} #overwrite in initialize

  htmlWrapper:(content)-> content #overwrite in initialize

  
FormItem = Backbone.View.extend
  ###
  @param base    - function which return base {jQuery} element which need to copy
  @param wrapper -  function(content) which wrap 
                    content {String|html} with underscore template
  ###
  initialize:(options)->
    @base = options.base
    @htmlWrapper = (content)-> options.wrapper(content)
    @render()

  render:->
    content = @htmlWrapper _.template( @templateHTML(), @templateData())     
    @$el.html content

  templateHTML:-> @base().data RenderView::DATA_TEMPLATE

  templateData:-> @base().data RenderView::DATA_DATA

  htmlWrapper:(content)-> content #overwrite in initialize


DragView = Backbone.View.extend
  initialize:(options)->
    @$el.draggable
      appendTo:"body"
      helper:"clone"

DropView = Backbone.View.extend
  events:
    "click *[data-js-close]": "event_close"

  initialize:(options)->    
    @$el.droppable(
      accept: options.accept
      activeClass:"drag-default"
      hoverClass:"drag-hover"      
      drop:(ev,ui)->
        $item = $("<li>").addClass("form-item").attr("data-js-close-panel","")
        $(this).find(".placeholder").before $item
        formItem = new FormItem
          el: $item
          base: -> ui.draggable  
          wrapper: options.wrapper      
    )
    @$el.sortable()

  event_close:(e)->
    $(e.target).parents("*[data-js-close-panel]").remove()


$(document).ready ->  
  _.each $("*[data-ui-jsrender]"), (el)->
    $(el).data "$view", new RenderView
      el:el
      data:-> $(el).data("ui-jsrender")
      wrapper:(content)-> 
        template = _.template $(".ui_tools *[data-ui-wrapper]:first").html()
        template content:content

  _.each $("*[data-drag-accept]"), (el)->
    dragView = new DragView el:el

  _.each $("*[data-drop-accept]"), (el)->
    dropView = new DropView 
      el:el
      accept: $(el).data("drop-accept")
      wrapper:(content)->
        templateHtml = $(".ui_workarea *[data-ui-wrapper]:first").html()
        templateHtml = templateHtml or "<div><%= content %></div>"
        _.template templateHtml, content:content
  