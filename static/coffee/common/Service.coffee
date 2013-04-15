define [
  "jquery",  
  "underscore",
  "view/FormItem-view"
  "common/Log"
],($,_,FormItemView,Log)->

  log = Log.getLogger("common/Service")

  Service=->
    @initialize.apply this, arguments
    this

  Service::=
    constructor:Service
    toolData:{}
    editableModel:null
    eventWire:{}
    ###
    --OPTIONS--
    @param dataToolBinder
    
    @param dataPostfixModalType - data-* postfix for search modal-items templates
    @param modal - 
    ###
    initialize:(options)->
      @_bindWire()
      @toolData = @getToolData options.dataToolBinder

    getData:(type)->
      @toolData[type]

    getItemFormTypes:-> _.keys @toolData

    getTemplateMetaData:(type)->
      @getData(type)?.meta

    getTemplateData:(type)->
      data = @getData(type)?.data ? {}
      data.id = _.uniqueId('tmpl');
      data
      
    getTemplate:(type)->
      @getData(type)?.template

    parceModalItemData:($body)->
      log.info "parceModalItemData"
      pattern = "input[name], select[name]"
      _.reduce $body.find(pattern),((memo,item)=>
        name = $(item).attr("name")
        if name? and name != ""
          memo[name] = @convertData $(item).val(), $(item).data("type")
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
        [data, meta] = [{},{}]
        _.each $el.data(toolBinder),(v,k)->
          if _.isString(v)
            data[k] = v
            meta[k] = ""
          else if _.isObject(v)          
            data[k] = if v.value? then v.value else ""
            meta[k] = if v.type? then v.type else ""

        memo[type] =
          type: type
          data : data
          meta : meta
          img : $el.data(toolBinder+"-img")
          template : $el.html()
          $el: $el
        memo
      ),{}

    _bindWire:->
      log.info "_bindWire"
      _.extend @eventWire, Backbone.Events
      @eventWire.on "editableModel:change", _.bind(@on_editableModel_change,this)


    on_editableModel_change:(model)->
      log.info "on_editableModel_change"
      @editableModel = model
      @eventWire.trigger("editableModel:set",model)


    setEditableModel:(model)->
      log.info "setEditableModel"
      unless @editableModel is model
        @eventWire.trigger("editableModel:change",model)
        true
      else
        false

    getEditableModel:-> @editableModel

  Service