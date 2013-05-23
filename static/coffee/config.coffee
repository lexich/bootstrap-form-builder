require.config
  baseUrl:"$STATIC_FOLDER$js"
  paths:
    "jquery":"jquery/jquery"
    "underscore":"underscore/underscore"
    "backbone":"backbone/backbone"
    "bootstrap":"bootstrap/bootstrap"
    "base":"common/base"
    "jasmine-html":"jasmine/jasmine-html"
    "jasmine":"jasmine/jasmine"
    "select2":"select2/select2"
    "datepicker":"datepicker/bootstrap-datepicker"
    "sortable":"jquery-ui/jquery.ui.sortable.patch"
    "draggable":"jquery-ui/jquery.ui.draggable"
    "droppable":"jquery-ui/jquery.ui.droppable"
    "spinner":"fuelux/spinner"
    "fuelux":"fuelux/all.min"

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

    "html2canvas/html2canvas":
      exports:"html2canvas"

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

    "droppable":
      deps:["jquery-ui/jquery.ui.mouse"]

    "draggable":
      deps:["jquery-ui/jquery.ui.mouse"]
    
    "jquery-ui/jquery.ui.resizable":
      deps:["jquery-ui/jquery.ui.mouse"]

    "sortable":
      deps:["jquery-ui/jquery.ui.sortable"]