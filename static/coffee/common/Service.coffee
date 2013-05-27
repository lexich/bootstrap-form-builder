define [
  "jquery",
  "backbone"
  "underscore",
  "view/FormItem-view"
  "common/Log"
],($, Backbone, _,FormItemView,Log)->

  log = Log.getLogger("common/Service")

  parseBoolean = (val)->
    if val in ["true","on"] then true else false

  Service=->
    @initialize.apply this, arguments
    this

  _.extend Service.prototype, Backbone.Events,
    constructor:Service
    toolData:{}
    editableView:null
    ###
    --OPTIONS--
    @param dataToolBinder
    
    @param dataPostfixModalType - data-* postfix for search modal-items templates
    @param modal - 
    ###
    initialize:(options)->
      @toolData = @getToolData options.dataToolBinder
      @listenTo this, "editableView:change", @on_editableView_change

    getData:(type)-> @toolData[type]

    getItemFormTypes:-> _.keys @toolData

    getTemplateMetaData:(type)->
      @getData(type)?.meta

    getTemplateData:(type)->
      data = @getData(type)?.data ? {}
      data.id = _.uniqueId(type)
      data
      
    getTemplate:(type)->
      @getData(type)?.template

    parceModalItemData:($body)->
      log.info "parceModalItemData"
      pattern = "input[name], select[name]"
      _.reduce $body.find(pattern),((memo,item)=>
        name = $(item).attr("name")
        if name? and name != ""
          if $(item).attr("type") == "checkbox"
            value = $(item).is(":checked")
          else
            value = $(item).val()
          memo[name] = @convertData value, $(item).data("type")
        memo
      ),{}

    convertData:(val,type)->
      log.info "convertData"
      if type is 'int' then parseInt(val)
      else if type is 'float' then parseFloat(val)
      else val

    getToolData:(toolBinder)->
      log.info "getToolData"
      _.reduce $("*[data-#{toolBinder}]"),((memo, el)=>
        $el = $(el)
        type = $el.data(toolBinder+"-type")
        [data, meta, title, list] = [{},{},{}, {}]
        _.each $el.data(toolBinder),(v,k)=>
          if _.isString(v)
            data[k] = v
            meta[k] = ""
            title[k] = k
            list[k] = _.bind(@getItemFormTypes,this)
          else if _.isObject(v)
            data[k] = if v.value? then v.value else ""
            meta[k] = if v.type? then v.type else ""
            title[k] = if v.title? then v.title else k
            list[k] = if v.data? then v.data else _.bind(@getItemFormTypes,this)

        memo[type] = {
          type, data, meta, $el, list
          title: $el.data("title") ? data.title
          settingsTitle:title
          img : $el.data(toolBinder+"-img")
          template : $el.html()
        }
        memo
      ),{}

    on_editableView_change:(view)->
      log.info "on_editableView_change"
      @editableView = view
      @trigger("editableView:set",view)


    setEditableView:(view)->
      log.info "setEditableView"
      unless @editableView is view
        @trigger("editableView:change", view)
        true
      else
        false

    getEditableModel:->
      log.error "getEditableModel"
      @editableView?.model

  Service