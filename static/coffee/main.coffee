require [  
  "jquery"
  "backbone"
  "view/Modal-view"
  "common/Service"
  "collection/FormItem-collection"
  "view/Form-view"
  "view/ToolItem-view"
  "view/Settings-view"
  "view/NotVisual-view"
  "common/Log"
  "html2canvas/html2canvas"
  "bootstrap"

],($, Backbone,
   ModalView,
   Service,
   FormItemCollection,
   FormView,
   ToolItemView,
   SettingsView,
   NotVisualView,
   Log,
   html2canvas
)->
  DEBUG = Log.LEVEL.DEBUG
  INFO = Log.LEVEL.INFO
  WARN = Log.LEVEL.WARN
  ERROR = Log.LEVEL.ERROR
  CHECK = WARN | ERROR
  ALL = DEBUG | INFO | WARN | ERROR

  Log.initConfig {
    "view/FormView": level: CHECK
    "view/FieldsetView": level: CHECK
    "view/FormItemView": level: CHECK
    "view/ModalView": level: CHECK
    "view/RowView": level: CHECK
    "view/SettingsView": level: CHECK
    "view/ToolItemView": level: CHECK
    "view/NotVisual": level: ALL
    "common/CustomView": level: CHECK
    "common/Service": level: CHECK
    "collection/FormItemCollection": level: CHECK
    "collection/FieldsetCollection": level: CHECK
    "main":level:CHECK
  }

  log = Log.getLogger("main")

  initCsrf = ->
    sameOrigin = (url) ->

      # url could be relative or scheme relative or absolute
      host = document.location.host # host + port
      protocol = document.location.protocol
      sr_origin = "//" + host
      origin = protocol + sr_origin

      # Allow absolute or scheme relative URLs to same origin

      # or any other URL that isn't scheme relative or absolute i.e relative.
      (url is origin or url.slice(0, origin.length + 1) is origin + "/") or (url is sr_origin or url.slice(0, sr_origin.length + 1) is sr_origin + "/") or not (/^(\/\/|http:|https:).*/.test(url))
    safeMethod = (method) ->
      /^(GET|HEAD|OPTIONS|TRACE)$/.test method
    $el = $("meta[name=\"CSRFToken\"]")
    unless $el.length is 1
      log.warn "initCsrf - meta csrf not found"
      return
    csrfToken = $el.attr("content")
    $(document).ajaxSend (event, xhr, settings) ->
      xhr.setRequestHeader "CSRFToken", csrfToken  if not safeMethod(settings.type) and sameOrigin(settings.url)

  $(document).ready ->
    initCsrf()
    url = window.rootformconfig?.url ? "/forms.json"
    param = window.rootformconfig?.param ? "id"
    if url.indexOf("?") is -1 then url += "?"

    _.each window.location.search.replace("?","").split("&"),(query)->
      if query.indexOf("#{param}=") is 0 then url += "#{query}&"

    collection = new FormItemCollection {url}


    service = new Service
      dataToolBinder: "ui-jsrender"
      collection: collection
      areaTemplateItem: ""      
      dataPostfixModalType:"modal-type"

    formView = new FormView {
       className:"ui_workarea"
       el: $("[data-html-form]:first")
       dataDropAccept: "drop-accept"
       collection, service
    }

    notVisual = new NotVisualView
      className:"ui_notvisual"
      el:$("[data-html-notvisual]:first")
      collection:collection
      service:service

    settings = new SettingsView
      el: $("[data-html-settings]:first"),
      dataPostfixModalType:"modal-type"
      service:service
      collection:collection

    _.each service.toolData, (data,type)=>
      toolItem = new ToolItemView {type,service,data}
      toolItem.render()

    $("[data-js-global-form-save]").click ->
      html2canvas $("[data-html-form]:first")[0],
        onrendered: (canvas)->
          data = canvas.toDataURL()
          data = data.replace "data:image/png;base64,",""
          collection.updateAll img:data

    $("[data-js-global-debug]")
      .click ->
        $(this).toggleClass "icon-bookmark-empty"
        $(this).toggleClass "icon-bookmark"
        $("body").toggleClass "ui_debug"

    $("[data-js-global-saveimg]").click ->
      html2canvas $("[data-html-form]:first")[0],
        onrendered: (canvas)->
          data = canvas.toDataURL()
          window.open(data,"_blank")
    collection.fetch()
