define [
  "jquery",  
  "underscore",
  "view/FormItem-view"
],($,_,FormItemView)->
  Service=->
    @initialize.apply this, arguments
    this

  Service::=
    formItemViews:[]
    constructor:Service
    toolData:{}
    modalTemplates:{}  
    ###
    --OPTIONS--
    @param dataToolBinder
    
    @param dataPostfixModalType - data-* postfix for search modal-items templates
    @param modal - 
    ###
    initialize:(options)->      
      @toolData = @getToolData options.dataToolBinder
      toolPanelItem = _.map @toolData, (v,k)=>
        options.createToolItemView(this,k,v).render()

      @modal = options.modal
      formView = options.createFormView(this)

      @modalTemplates = _.reduce $("[data-#{options.dataPostfixModalType}]"),(
        (memo,item)->
          type = $(item).data(options.dataPostfixModalType)
          if type? and type != ""
            memo[type] = $(item).html()
          memo
      ),{}

    getOrAddFormItemView:(model, options)->
      options = options ? {}
      filterItem = _.filter @formItemViews, (view)->
        view.model is model

      if filterItem.length > 1
        filterItem[0]
      else
        options = _.extend(options, {model, service: this})
        item = new FormItemView options
        @formItemViews.push item
        item

    renderModalForm:(name,data)->
      @_renderModalFormCache = {} if _.isUndefined(@_renderModalFormCache) 
      return @_renderModalFormCache[name] if @_renderModalFormCache[name]?
      selector = "[data-ui-jsrender-modal-template='#{name}']:first" 
      $item = $(selector)
      if $item.length is 1
        _.each $("input,select,textarea",$item), (input)->
          $input = $(input)
          name = $input.attr("name")
          value = data[name]
          unless _.isUndefined(value)
            $input.val(value)        
      @_renderModalFormCache[name] = $item
      $item

    renderModalItemTemplate:(type,data)->
      if type is null or type is ""
        type = "input"
      templateHtml = @modalTemplates[type]
      if not templateHtml or templateHtml == ""
        templateHtml = @modalTemplates["input"]
      _.template templateHtml, data

    renderFormViewElement:(params)->
      params = _.extend {
        row:0
      }, params || {}
      $item = $ _.template $("#formViewTemplate").html(), params or {}
      

    showModal:(options)-> 
      @modal.show options

    getData:(type)->
      @toolData[type]

    getItemFormTypes:->
      _.keys @toolData

    getTemplateMetaData:(type)->
      @getData(type)?.meta

    getTemplateData:(type)->
      @getData(type)?.data
      
    getTemplate:(type)->
      @getData(type)?.template    
      

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

    renderFormItemTemplate:(html)->
      templateHtml = $("#formItemTemplate").html() or "<%= content %>"
      _.template templateHtml, content:html

  Service