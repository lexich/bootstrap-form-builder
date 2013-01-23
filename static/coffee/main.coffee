DATA_VIEW = "$view"
DATA_TYPE = "comonent-type"


FormItem = Backbone.View.extend
  PARAM_DATA:"form-item-data"
  events:
    "click *[data-js-close]" : "event_close"
    "click *[data-js-options]" : "event_options"
    "click *[data-js-popover-ok]": "event_okPopover"
    "click *[data-js-popover-cancel]": "event_cancelPopover"
  ###
  @param service
  @param type    
  ###
  initialize:(options)->    
    @service = options.service
    @type = options.type    
    @$el.data DATA_VIEW, this
    @updateData options.data
    @template = _.template @service.getTemplate(@type)
    @render()
  
  render:->
    data = @getData()
    content = @template data
    html = @service.renderFormItemTemplate content
    @$el.html html

  getData:->
    @$el.data @PARAM_DATA

  updateData:(data)->
    @$el.data @PARAM_DATA, data


  event_close:(e)->
    @$el.remove()

  event_options:(e)->    
    popoverContent = @service.renderPopoverTemplate @getData()
    $(e.target).data
      title: "Configuration"
      content: popoverContent
      html:true
    @popover = $(e.target).popover("show")
  
  event_okPopover:(e)->
    data = {}
    _.each $(".popover input",@$el), (item)->
      data[$(item).attr("name")] = $(item).val()
    @updateData(data)   
    @popover?.popover("hide")
    @render()

  event_cancelPopover:(e)->
    @popover?.popover("hide")



DropAreaView = Backbone.View.extend
  events:{}    

  initialize:(options)-> 
    @service = options.service    
    @events = _.extend @events,      
      "click *[data-js-submit-form]": "event_submitForm"

    @$el.droppable
      accept: options.accept
      activeClass:""
      hoverClass:""      
      drop: _.bind(@handle_droppable_drop,this)    
    @$el.sortable()

  handle_droppable_drop:(ev,ui)->  
    unless ui.draggable is ui.helper
      type = ui.draggable.data(DATA_TYPE)
      $item = $("<li>")
        .addClass("form-item")
        .append(ui.helper)

      @$el.find(".placeholder").before $item 
      formItem = new FormItem
        el: $item            
        type: type      
        service: @service
        data: @service.getTemplateData(type)

      $item.data DATA_VIEW, formItem

    

  event_submitForm:(e)->    
    @collection.sync()  


ToolItemView = Backbone.View.extend  
  ###
  @param data    -  function which return {Object} for underscore template  
  ###
  initialize: (options)->
    @service = options.service
    @type = options.type 
    @template = options.template   
    @$el.draggable
      appendTo:"body"
      clone:true
      helper:_.bind( @handle_draggable_helper, this)
    @render()

  handle_draggable_helper:(event)->
    $el = $(event.target)    
    templateHtml = @service.getTemplate @type
    data = @service.getTemplateData(@type)
    _.template templateHtml, data

  render:-> 
    data = @service.getData(@type)    
    @$el.html @template
    @$el.data DATA_TYPE, @type
    data.$el.before @$el


Service=->
  @initialize.apply this, arguments


Service::=  
  toolData:{}

  ###
  @param dataToolBinder    
  ###
  initialize:(options)->
    @toolData = @getToolData(options.dataToolBinder)    
    toolPanelItem = @createToolPanel(@toolData)
    @dropArea = @createDropArea $("*[data-drop-accept]")

  getData:(type)-> @toolData[type]
  getTemplateData:(type)-> @getData(type)?.data
  getTemplate:(type)-> @getData(type)?.template

  createDropArea:($el)->
    new DropAreaView
      el: $el
      service: this

  createToolPanel:(toolData)->        
    _.map toolData, (v,k)=>
      new ToolItemView
        type: k
        service:this
        template:@renderAreaItem(v)

  renderAreaItem:(data)->    
    htmlTemplate = $("#areaTemplateItem").html()    
    _.template htmlTemplate, data
    
    

  getToolData:(toolBinder)->
    result = {}
    _.each $("*[data-#{toolBinder}]"),(el)=>
      $el = $(el)
      type = $el.data(toolBinder+"-type")
      result[type] =
        type: type
        data : $el.data(toolBinder)      
        img : $el.data(toolBinder+"-img")
        template : $el.html()
        $el: $el
    result

  renderFormItemTemplate:(html)->
    templateHtml = $("#formItemTemplate").html() or "<%= content %>"
    _.template templateHtml, content:html

  renderPopoverTemplate:(data)->
    templateHtml = $("#popoverTemplate").html()
    _.template templateHtml, data:data



$(document).ready ->  
  service = new Service
    dataToolBinder: "ui-jsrender"
    areaTemplateItem: "" 