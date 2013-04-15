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
    formItemViews:[]
    constructor:Service
    toolData:{}
    modalTemplates:{}
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

      @modalTemplates = _.reduce $("[data-#{options.dataPostfixModalType}]"),(
        (memo,item)->
          type = $(item).data(options.dataPostfixModalType)
          if type? and type != ""
            memo[type] = $(item).html()
          memo
      ),{}



    renderSettingsForm:( type, data)->
      log.info "renderSettingsForm"
      $frag = $("<div>")
      $item = $("[data-ui-jsrender-modal-template='#{type}']:first")
      if $item.length is 1
        $frag.html $item.html()
        _.each $("input,select,textarea",$frag), (input)->
          $input = $(input)
          type = $input.attr("name")
          value = data[type]
          unless _.isUndefined(value)
            $input.val(value)
      else
        meta = @getTemplateMetaData(type)
        content = _.map data, (v,k)=>
          itemType = meta[k] ? "hidden"
          opts =
            name: k
            value: v
            data: @getItemFormTypes()
          tmpl = @renderModalItemTemplate itemType, opts
          tmpl
        $frag.html content.join("")
      $frag.children()

    renderModalItemTemplate:(type,data)->
      log.info "renderModalItemTemplate"
      if type is null or type is ""
        type = "input"
      templateHtml = @modalTemplates[type]
      if templateHtml? and templateHtml != ""
        _.template templateHtml, data
      else
        ""

    getData:(type)->
      @toolData[type]

    getItemFormTypes:->
      _.keys @toolData

    getTemplateMetaData:(type)->
      @getData(type)?.meta

    getTemplateData:(type)->
      data = @getData(type)?.data ? {}
      data.id = _.uniqueId('tmpl');
      data
      
    getTemplate:(type)->
      @getData(type)?.template

    parceModalItemData:($body)->
      pattern = "input[name], select[name]"
      _.reduce $body.find(pattern),((memo,item)=>
        name = $(item).attr("name")
        if name? and name != ""
          memo[name] = @convertData $(item).val(), $(item).data("type")
        memo
      ),{}

    convertData:(val,type)->
      if type is 'int' then parseInt(val)
      else if type is 'float' then parseFloat(val)
      else val

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