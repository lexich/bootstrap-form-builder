DATA_VIEW = "$view"
DATA_TYPE = "comonent-type"


FormItemView = Backbone.View.extend
  events:
    "click *[data-js-close]" : "event_close"
    "click *[data-js-options]" : "event_options"
    "click *[data-js-popover-ok]": "event_okPopover"
    "click *[data-js-popover-cancel]": "event_cancelPopover"
  ###
  @param service
  @param type
  ###
  initialize:->
    @model.on "change", => @render()
    @render()
  
  render:->
    templateHtml = @options.service.getTemplate @model.get("type")
    content = _.template templateHtml, @model.attributes
    html = @options.service.renderFormItemTemplate content
    @$el.html html

  event_close:->
    @model.destroy()
    @remove()

  event_options:(e)->
    popoverContent = @options.service.renderPopoverTemplate @model.attributes
    $(e.target).data
      title: "Configuration"
      content: popoverContent
      html:true
    @popover = $(e.target).popover("show")
  
  event_okPopover:(e)->
    data = _.reduce $(".popover input",@$el), ((memo,item)->
      memo[$(item).attr("name")] = $(item).val() and memo
    ),{}
    @model.set data
    @popover?.popover("hide")

  event_cancelPopover:(e)->
    @popover?.popover("hide")


DropAreaModel = Backbone.Model.extend
  defaults:
    label:""
    placeholder:""
    type:""

  validate:(attrs)->
    if attrs.label? and attrs.label != ""
      return "label mustn't be not null"
    if attrs.placeholder? and attrs.placeholder != ""
      return "placeholder mustn't be not null"
    if attrs.type? and attrs.type != ""
      return "type mustn't be not null"


DropAreaCollection = Backbone.Collection.extend
  url : "/forms.json"
  model : DropAreaModel
  updateAll: ->        
    options =
      success: (model, resp, xhr)=>
        @reset(model)      
    Backbone.sync 'create', this, options


DropAreaView = Backbone.View.extend
  events:{}

  initialize:->
    @events = _.extend @events,
      "click *[data-js-submit-form]": "event_submitForm"

    @$el.droppable
      accept: @options.accept
      activeClass:""
      hoverClass:""
      drop: _.bind(@handle_droppable_drop,this)
    @$el.sortable()

  render:->
    @$el.html()
    _.each @collection.models, (model)=>
      $item = @createItem model
      @$el.find(".placeholder").before $item


  handle_droppable_drop:(ev,ui)->
    unless ui.draggable is ui.helper
      type = ui.draggable.data(DATA_TYPE)
      
      data = @options.service .getTemplateData(type)
      model = @collection.create data
      $item = @createItem model

      $items = @$el.children()
      pos = ev.clientY
      for i in [0..$items.length-1]
        $it = $ $items[i]
        top = $it.position().top
        height = $it.height()
        if top <= pos and pos <= top + height
          if top + height/2 > pos
            $it.before $item
          else
            $it.after $item
          return

      $item.appendTo @$el

  createItem:(model)->
    $item = $("<li>")
        .addClass("form-item")
    
    formItem = new FormItemView
      el: $item
      model: model
      service: @options.service
    $item.data DATA_VIEW, formItem
    $item

  event_submitForm:(e)->
    @collection.updateAll()


ToolItemView = Backbone.View.extend
  ###
  @param data    -  function which return {Object} for underscore template  
  ###
  initialize:->
    @$el.draggable
      appendTo:"body"
      clone:true
      helper:_.bind( @handle_draggable_helper, this)
    @render()

  handle_draggable_helper:(event)->
    $el = $(event.target)
    templateHtml = @options.service.getTemplate @options.type
    data = @options.service.getTemplateData(@options.type)
    _.template templateHtml, data

  render:-> 
    data = @options.service.getData(@options.type)
    @$el.html @options.template
    @$el.data DATA_TYPE, @options.type
    data.$el.before @$el


Service=->
  @initialize.apply this, arguments


Service::=
  constructor:Service
  toolData:{}

  ###
  @param dataToolBinder
  ###
  initialize:(options)->
    @toolData = @getToolData(options.dataToolBinder)
    toolPanelItem = @createToolPanel(@toolData)
    
    @dropArea = @createDropArea $("*[data-drop-accept]")

  getData:(type)-> @toolData[type]
  getTemplateMetaData:(type)->
    @getData(type)?.data
  getTemplateData:(type)->
    _.reduce @getTemplateMetaData(type),
      ((memo,v,k)->
        if _.isString(v) 
          memo[k] = v
        else if _.isObject(v)
          memo[k] = v.value
        memo
      ),{}
    
  getTemplate:(type)-> @getData(type)?.template

  createDropArea:($el)->
    collection = new DropAreaCollection
    item = new DropAreaView
      el: $el
      service: this
      collection: collection
    collection.on "reset", =>
      item.render()
    collection.fetch()
    item

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
    _.reduce $("*[data-#{toolBinder}]"),((memo, el)=>
      $el = $(el)
      type = $el.data(toolBinder+"-type")
      memo[type] =
        type: type
        data : $el.data(toolBinder)
        img : $el.data(toolBinder+"-img")
        template : $el.html()
        $el: $el
      memo
    ),{}

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