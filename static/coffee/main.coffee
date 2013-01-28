require.config
  baseUrl:"static/js"
  paths:
    "jquery":"jquery/jquery"
    "underscore":"underscore/underscore"
    "backbone":"backbone/backbone"
    "bootstrap":"bootstrap/bootstrap"
    "base":"common/base"
  shim:
    "underscore":
      exports:"_"
    "backbone":
      deps:["underscore","jquery"]
      exports:"Backbone"
    "bootstrap":
      deps:["jquery"]

    #jquery ui
    "jquery-ui/jquery.ui.core":
      deps:["jquery"]
    "jquery-ui/jquery.ui.widget":
      deps:["jquery-ui/jquery.ui.core"]
    
    "jquery-ui/jquery.ui.mouse":
      deps:["jquery-ui/jquery.ui.widget"]
    
    "jquery-ui/jquery.ui.sortable":
      deps:["jquery-ui/jquery.ui.mouse"]

    "jquery-ui/jquery.ui.droppable":
      deps:["jquery-ui/jquery.ui.mouse"]

    "jquery-ui/jquery.ui.draggable":
      deps:["jquery-ui/jquery.ui.mouse"]
    
    "jquery-ui/jquery.ui.resizable":
      deps:["jquery-ui/jquery.ui.mouse"]

require [
  "jquery",
  "/static/js/view/Modal-view.js",
  "/static/js/common/Service.js",
  "collection/DropArea-collection",
  "view/Form-view",
  "view/ToolItem-view"
],($,ModalView,Service,DropAreaCollection,FormView,ToolItemView)->
  $(document).ready ->
    modal = new ModalView
      html:$("#modalTemplate").html()
    collection = new DropAreaCollection
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
      
    $("#modal").click ->
      service.showModal ($el,$body)->
        $body.append $("p").text("Hello world")