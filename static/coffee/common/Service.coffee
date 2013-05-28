define [
  "jquery",
  "backbone"
  "underscore",
  "view/FormItem-view"
  "common/Log"
],($, Backbone, _,FormItemView,Log)->

  log = Log.getLogger("common/Service")

  ServiceModel = do(__super__=->)->
    __super__:: =
      data:{}
      add:(type, item, extra)->
        data = @parce(item) ? {}
        @data[type] = _.defaults extra, data
        this

      get:(type)-> @data[type]

      keys:-> _.keys @data

      items:-> @data

      parce:(items)->
        _.reduce items,((memo,v,k)=>
          if _.isString(v)
            @_parceString k, v, memo
          else
            @_parceObject k, v, memo
        ), data:{}, meta:{}, settingsTitle:{}, list:{}


      _parceString:(k, v, memo)->
        memo.data[k] = v
        memo.meta[k] = ""
        memo.settingsTitle[k] = k
        memo.list[k] = []
        memo

      _parceObject:(k, v, memo)->
        memo.meta[k] = if v.type? then v.type else ""
        if memo.meta[k] is "list"
          memo.data[k] = if v.value? then v.value.split("\n") else []
        else
          memo.data[k] = if v.value? then v.value else ""
        memo.settingsTitle[k] = if v.title? then v.title else k
        memo.list[k] = if v.data? then v.data else []
        memo
    __super__


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
      @static_folder = options.static_folder
      @toolData = @getToolData options.dataToolBinder
      @listenTo this, "editableView:change", @on_editableView_change

    insertToolItemEl:(type, $el)->
      data = @getData(type)
      if @static_folder? and data.img?
        path = "url(\"#{@static_folder}#{data.img}\")"
        $el.css "background-image":path
      data.$el.before $el

    getItems:-> @toolData.items()

    getData:(type)-> @toolData.get(type)

    getDataList:(type)-> @toolData.get(type).list

    getDataSettingsTitle:(type)-> @toolData.get(type).settingsTitle

    getItemFormTypes:-> @toolData.keys()

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
      pattern = "input[name], select[name], textarea[name]"
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
      else if type is 'list' then val.trim().split("\n")
      else val

    getToolData:(toolBinder)->
      log.info "getToolData"

      _.reduce $("*[data-#{toolBinder}]"),((memo, el)=>
        $el = $(el)
        type = $el.data(toolBinder+"-type")
        memo.add type, $el.data(toolBinder), {
          type, $el
          title: $el.data("title") ? type
          img : $el.data(toolBinder+"-img")
          template : $el.html()
        }
      ), new ServiceModel

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