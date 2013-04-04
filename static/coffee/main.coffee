require [  
  "jquery"
  "backbone"
  "view/Modal-view"
  "common/Service"
  "collection/FormItem-collection"
  "view/Form-view"
  "view/ToolItem-view"
  "view/Settings-view"
  "bootstrap"
],($, Backbone,
   ModalView,
   Service,
   FormItemCollection,
   FormView,
   ToolItemView,
   SettingsView
)->
  $(document).ready ->

    settings = new SettingsView
      el: $("[data-html-settings]:first")

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
      settings: settings
      
    collection.fetch()