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
  "/static/js/common/Service.js"
],($,ModalView,Service)->
  $(document).ready ->
    modal = new ModalView
      html:$("#modalTemplate").html()
    service = new Service
      dataToolBinder: "ui-jsrender"
      areaTemplateItem: ""
      dataPostfixDropAccept:"drop-accept"
      dataPostfixModalType:"modal-type"
      modal: modal
      
    $("#modal").click ->
      service.showModal ($el,$body)->
        $body.append $("p").text("Hello world")