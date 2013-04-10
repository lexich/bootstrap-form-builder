require [  
  "jquery"
  "backbone"
  "view/Modal-view"
  "common/Service"
  "collection/FormItem-collection"
  "view/Form-view"
  "view/ToolItem-view"
  "view/Settings-view"
  "common/Log"
  "bootstrap"
],($, Backbone,
   ModalView,
   Service,
   FormItemCollection,
   FormView,
   ToolItemView,
   SettingsView,
   Log
)->
  DEBUG = Log.LEVEL.DEBUG
  INFO = Log.LEVEL.INFO
  WARN = Log.LEVEL.WARN
  ERROR = Log.LEVEL.ERROR
  ALL = DEBUG | INFO | WARN | ERROR

  Log.initConfig {
#    "view/FormView": level: ALL
#    "view/FieldsetView": level: ALL
#    "view/APIView": level: ALL
    "view/FormItemView": level: ALL
#    "view/ModalView": level: ALL
    "view/RowView": level: ALL
#    "view/SettingsView": level: ALL
#    "view/ToolItemView": level: ALL
#    "common/CustomView": level: ALL
#    "common/Service": level: ALL
#    "collection/FormItemCollection": level: ALL
#    "collection/FieldsetCollection": level: ALL
  }

  $(document).ready ->

    collection = new FormItemCollection
      url:"/forms.json"

    createFormView = (service)-> 
      new FormView {
         className:"ui_workarea"
         el: $("[data-html-form]:first")
         dataDropAccept: "drop-accept"
         collection, service, settings
      }

    createToolItemView = (service,type,data)->
      new ToolItemView
          type: type
          service:service
          template:service.renderAreaItem(data) 

    service = new Service
      dataToolBinder: "ui-jsrender"
      collection: collection
      createFormView:createFormView
      createToolItemView:createToolItemView
      areaTemplateItem: ""      
      dataPostfixModalType:"modal-type"

    settings = new SettingsView
      el: $("[data-html-settings]:first")
      service:service

      
    collection.fetch()

    $("[data-js-global-form-save]").click ->
      collection.updateAll()

    $("[data-js-global-debug]")
      .click ->
        $(this).toggleClass "icon-bookmark-empty"
        $(this).toggleClass "icon-bookmark"
        $("body").toggleClass "ui_debug"
