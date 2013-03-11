require.config
  baseUrl:"static/js"
  paths:
    "jquery":"jquery/jquery"
    "underscore":"underscore/underscore"
    "backbone":"backbone/backbone"
    "bootstrap":"bootstrap/bootstrap"
    "base":"common/base"
    "jasmine-html":"jasmine/jasmine-html"
    "jasmine":"jasmine/jasmine" 
    "select2":"../plugins/select2/select2"
    "datepicker":"../plugins/datepicker/js/bootstrap-datepicker"
  shim:
    "jasmine":
      exports:"jasmine" 
      
    "jasmine-html":
      deps:["jasmine"]

    "underscore":
      exports:"_"
    "backbone":
      deps:["underscore","jquery"]
      exports:"Backbone"
    "bootstrap":
      deps:["jquery"]

    "datepicker":
      deps:["bootstrap"]

    "select2":
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