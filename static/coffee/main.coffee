require [  
  "jquery"
  "view/Modal-view"
  "common/Service"
  "collection/FormItem-collection"
  "view/Form-view"
  "view/ToolItem-view"
  "view/Settings-view"
  "bootstrap"
],($,
   ModalView,
   Service,
   FormItemCollection,
   FormView,
   ToolItemView,
   SettingsView
)->
  $(document).ready ->
    modal = new ModalView
      html:$("#modalTemplate").html()

    settings = new SettingsView
      el: $("[data-html-settings]:first")

    collection = new FormItemCollection
      url:"/forms.json"

    createFormView = (service)-> 
      new FormView
        className:"ui_workarea"
        el: $("[data-html-form]:first")
        collection: collection
        service: service
        dataDropAccept: "drop-accept"

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
      modal: modal
      settings: settings
      
    collection.fetch()