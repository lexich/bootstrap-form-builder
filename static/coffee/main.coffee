DATA_VIEW = "$view"
DATA_TYPE = "comonent-type"


FormItemView = Backbone.View.extend
  events:
    "click *[data-js-close]" : "event_close"
    "click *[data-js-options]" : "event_options"    
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
    @$el.sortable
      axis: "y"      

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
      len = $items.length-1
      if len > 0
        for i in [0..len]
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
  this


Service::=
  constructor:Service
  toolData:{}
  modalTemplates:{}
  ###
  --OPTIONS--
  @param dataToolBinder
  @param dataPostfixDropAccept - data-* postfix for search drop area
  @param dataPostfixModalType - data-* postfix for search modal-items templates
  @param modal - 
  ###
  initialize:(options)->
    @options = options
    @toolData = @getToolData @options.dataToolBinder
    toolPanelItem = @createToolPanel @toolData
    @modal = options.modal 
    @dropArea = @createDropArea @options.dataPostfixDropAccept
    @modalTemplates = @getModalTemplates @options.dataPostfixModalType


  getModalTemplates:(dataModalType)->
    _.reduce $("*[data-#{dataModalType}]"),((memo,item)->
      type = $(item).data(dataModalType)
      if type? and type != ""
        memo[type] = $(item).html()
      memo
    ),{}

  renderModalItemTemplate:(type,data)->
    if type is null or type is ""
      type = "input"
    templateHtml = @modalTemplates[type]
    if templateHtml is null or templateHtml == ""
      templateHtml = @modalTemplates["input"]
    _.template templateHtml, data

  showModal:(options)-> 
    @modal.show options

  getData:(type)-> @toolData[type]

  getItemFormTypes:-> _.keys @toolData

  getTemplateMetaData:(type)->
    @getData(type)?.meta

  getTemplateData:(type)->
    @getData(type)?.data
    
  getTemplate:(type)-> @getData(type)?.template

  createDropArea:(dropAccept)->
    $el = $("[data-#{dropAccept}]:first")
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

  parceModalItemData:($body)->
    pattern = "input[name], select[name]"
    _.reduce $body.find(pattern),((memo,item)->
      name = $(item).attr("name")
      if name? and name != ""
        memo[name] = $(item).val()
      memo
    ),{}  

  renderAreaItem:(data)->
    htmlTemplate = $("#areaTemplateItem").html()
    _.template htmlTemplate, data

  getToolData:(toolBinder)->
    _.reduce $("*[data-#{toolBinder}]"),((memo, el)=>
      $el = $(el)
      type = $el.data(toolBinder+"-type")
      [data, meta] = [{},{}]
      _.each $el.data(toolBinder),(v,k)->
        if _.isString(v)
          data[k] = v
          meta[k] = ""
        else if _.isObject(v)
          data[k] = v.value or ""
          meta[k] = v.type or ""

      memo[type] =
        type: type
        data : data
        meta : meta
        img : $el.data(toolBinder+"-img")
        template : $el.html()
        $el: $el
      memo
    ),{}

  renderFormItemTemplate:(html)->
    templateHtml = $("#formItemTemplate").html() or "<%= content %>"
    _.template templateHtml, content:html  


ModalView = Backbone.View.extend
  DEFAULT_MODAL_BODY:".modal-body"
  events:
    "click *[data-js-close]":"event_close"
    "click *[data-js-save]":"event_save"

  initialize:->
    @$el.hide()
    @$el.html @options.html
    @$el.appendTo $("body")
    @options.classModalBody = @options.classModalBody || @DEFAULT_MODAL_BODY
    

  show:(options)->
    @callback_preRender = ($el, $body)=> options?.preRender $el, $body
    @callback_postSave = ($el, $body)=> options?.postSave $el, $body
    @render()
    @$el.show()

  hide:->     
    @$el.hide()

  render:->
    @$el.css
      width: $(window).width()
      height: $(window).height()
      top:0
      left:0      
      position: "absolute"     
    @callback_preRender @$el, $(@options.classModalBody, @$el)
    
  callback_preRender: ($el, $body)->
  callback_postSave: ($el, $body)->

  event_close:-> 
    @hide()

  event_save:->    
    @hide()
    @callback_postSave @$el, $(@options.classModalBody, @$el)


$(document).ready ->
  modal = new ModalView
    html:$("#modalTemplate").html()
  service = new Service
    dataToolBinder: "ui-jsrender"
    areaTemplateItem: ""
    dataPostfixDropAccept:"drop-accept"
    dataPostfixModalType:"modal-type"
    modal: modal
    
  $("#modal").click ->    
    service.showModal ($el,$body)->
      $body.append $("p").text("Hello world")