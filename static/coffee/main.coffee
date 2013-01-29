require [  
  "jquery",
  "view/Modal-view",
  "common/Service",
  "collection/DropArea-collection",
  "view/Form-view",
  "view/ToolItem-view",
],($,ModalView,Service,DropAreaCollection,FormView,ToolItemView)->
  $(document).ready ->
    modal = new ModalView
      html:$("#modalTemplate").html()

    collection = new DropAreaCollection
      url:"/forms.json"

    createFormView = (service)-> 
      new FormView
        className:"ui_workarea"
        el: $("form")
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
      
    collection.fetch()