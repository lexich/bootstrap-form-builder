define [
  "jquery",  
  "underscore",  
],($,_)->
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
    
    @param dataPostfixModalType - data-* postfix for search modal-items templates
    @param modal - 
    ###
    initialize:(options)->
      @options = options
      @toolData = @getToolData @options.dataToolBinder
      toolPanelItem = _.map @toolData, (v,k)=>
        options.createToolItemView(this,k,v)
        
      @modal = options.modal
      
      formView = @options.createFormView(this)

      @modalTemplates = @getModalTemplates @options.dataPostfixModalType
      @options.collection.fetch()

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

    renderFormViewElement:($el)->
      $item = $ _.template $("#formViewTemplate").html(), {}
      $item.appendTo $el
      $item

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