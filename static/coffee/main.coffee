DATA_VIEW = "$view"
DATA_TYPE = "component-type"

LOG = (type,msg)->
  #console.log "#{type} #{msg}"
toInt = (v)-> if v is "" then 0 else parseInt v
isPositiveInt = (v)-> /^\d+$/.test v

FormView = Backbone.View.extend
  events:
    "click *[data-js-submit-form]": "event_submitForm"
    "click [data-js-add-drop-area]": "event_addDropArea"

  dropAreas:{}

  initialize:->
    @getOrAddDropArea(0)
    @collection.on "reset", _.bind(@_resetCollection,this)

  _resetCollection:->
    ###
    index models in row
    ###    
    rowModels = _.groupBy(@collection.models,(model)->
        model.get("row")
    )
    _.each rowModels,(models,row)=>
      models = _.sortBy(models, (model)-> model.get("position"))
      _.reduce models,((prev,model)->
        model.set {position:prev+1},{silent:true}
        prev + 1
      ),-1
      row = toInt row
      area = @getOrAddDropArea(row)
      area.render()
      area

  getOrAddDropArea:(row)->
    unless row? then row = _.size(@dropAreas)
    area = @dropAreas[row]
    unless area?
      area = new DropAreaView
        className:"#{@className}__placeholder"
        service: @options.service
        collection: @collection
        row:row
        accept:($el)->
          $el.hasClass "ui-draggable"
      @dropAreas[row] = area
      area.$el.appendTo @$el
    area

  event_submitForm:(e)->
    @collection.updateAll()

  event_addDropArea:(e)->
    keys = _.keys(@dropAreas)    
    nextRow = if keys.length > 0 then _.max(keys)+1 else 0
    @getOrAddDropArea nextRow

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

###
DropArea
###
DropAreaModel = Backbone.Model.extend
  defaults:
    label:""
    placeholder:""
    type:"input"
    name:""
    position:0
    row:0

  parse:(attrs, options)->
    intParams = _.reduce @defaults, (
      (memo,v,k)->
        if isPositiveInt(v) then memo.push k
        memo
    ),[]
    result = _.reduce attrs, ((memo, v,k)->
      if k in intParams
        memo[k] = toInt(v)
      else
        memo[k] = v
      memo
    ),{}
    result

  validate:(attrs)->
    if attrs.label is null or attrs.label is ""
      return "label mustn't be not null"
    if attrs.placeholder is null or attrs.placeholder is ""
      return "placeholder mustn't be not null"
    if attrs.type is null or attrs.type is ""
      return "type mustn't be not null"
    if attrs.position is null or attrs.position < 0
      return "position must be >= 0"
    if attrs.row is null or attrs.row < 0
      return "row must be >= 0"


DropAreaCollection = Backbone.Collection.extend
  url : "/forms.json"
  model : DropAreaModel
  parse:(attrs,options)->
    attrs
  comparator:(model)->
    model.get("row") * 1000 + model.get("position")
  updateAll: ->
    options =
      success: (model, resp, xhr)=>
        @reset(model)
    Backbone.sync 'create', this, options


DropAreaView = Backbone.View.extend
  row:0
  formItemViews:[]
  initialize:->
    @row = @options.row
    @$el.attr("data-drop-accept","")
    @$el.droppable
      accept: @options.accept
      drop: _.bind(@handle_droppable_drop,this)
    @$el.sortable
      axis: "y"

  render:->
    @$el.empty()
    _.each @collection.where(row:@row), (model)=>
      view = @getOrAddFormItemView(model)
      view.$el.appendTo @$el

  getOrAddFormItemView:(model)->
    filterItem = _.filter @formItemViews, (view)->
      view.model is model
    if filterItem.length > 1
      filterItem[0]
    else
      item = new FormItemView
        model: model
        service: @options.service
      @formItemViews.push item
      item

  reindex:->
    position = 0
    _.each $(".ui-draggable",@$el), (el)=>
      view = $(el).data DATA_VIEW
      model = view?.model
      model?.set
        position: position++
        row:@row
    @formItemViews = _.sortBy @formItemViews,(view)->
      view?.model?.get("position")

  handle_droppable_drop:(ev,ui)->
    view = ui.helper.data DATA_VIEW
    view?.remove()
    ui.draggable.empty()
    type = ui.draggable.data(DATA_TYPE)
    data = @options.service.getTemplateData(type)
    data.row = @row
    model = new DropAreaModel(data)
    @collection.push model
    view = new FormItemView
      el:$("<div>")
      model: model
      service: @options.service
    ui.helper.data DATA_VIEW, view
    view.$el.appendTo ui.draggable
    setTimeout (=>@reindex()), 0


ToolItemView = Backbone.View.extend
  ###
  @param data    -  function which return {Object} for underscore template  
  ###
  initialize:->
    @$el.draggable
      appendTo:"body"
      clone:true
      connectToSortable:"[data-drop-accept]"
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
    @$el.attr "data-#{DATA_TYPE}", @options.type
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

    collection = new DropAreaCollection

    formView = new FormView
      className:"ui_workarea"
      el: $("form")
      collection: collection
      service: this
      dataDropAccept: @options.dataPostfixDropAccept

    @modalTemplates = @getModalTemplates @options.dataPostfixModalType
    collection.fetch()

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
    if not templateHtml or templateHtml == ""
      templateHtml = @modalTemplates["input"]
    _.template templateHtml, data

  showModal:(options)-> 
    @modal.show options

  getData:(type)-> @toolData[type]

  getItemFormTypes:->
    _.keys @toolData

  getTemplateMetaData:(type)->
    @getData(type)?.meta

  getTemplateData:(type)->
    @getData(type)?.data
    
  getTemplate:(type)-> @getData(type)?.template

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