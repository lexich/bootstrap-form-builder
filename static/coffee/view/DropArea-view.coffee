define [
  "jquery",
  "backbone",
  "underscore",
  "view/FormItem-view",
  "model/DropArea-model"
  "jquery-ui/jquery.ui.draggable",
  "jquery-ui/jquery.ui.droppable"
  "jquery-ui/jquery.ui.sortable"  
],($,Backbone,_,FormItemView,DropAreaModel)->
  DropAreaView = Backbone.View.extend
    events:
      "click [data-js-close-area]":"event_close"
      "click [data-js-options-area]":"event_options"
    row:0
    
    className:"ui_workarea__placeholder"
    ###
    @param options
      - row
      - accept
      - formview
      - service
    ###
    initialize:->
      @row = @options.row
      
      @$el.html @options.service.renderFormViewElement
        row: @row
      
      @$area = @$el.find("[data-drop-accept]")

      @$area.droppable
        accept: @options.accept
        drop: _.bind(@handle_droppable_drop,this)

      @$area.sortable
        axis: "y"
        connectWith:"[data-drop-accept]"
        receive:_.bind(@handle_sortable_receive,this)
        update:_.bind(@handle_sortable_update,this)

    setRow:(row)->
      @$el.find("[data-html-row]").html("row: #{row}")
      @row = row

    event_close:(e)->
      _.each @$el.find("[data-drop-accept]").children(), (el)->
        view = $(el).data DATA_VIEW
        view?.remove()
      @options.formview?.removeDropArea this
      @remove()

    event_options:(e)->
          
    render:->      
      LOG "DropAreaView", "render"
      @$area.empty()
      models = @collection.where(row:@row)
      _.each models, (model)=>
        view = @options.service.getOrAddFormItemView(model)
        view.$el.appendTo @$area
        view.render()
     

    reindex:->
      LOG "DropAreaView","reindex"
      _.reduce @$area.children(), ((position,el)=>
        view = $(el).data DATA_VIEW
        model = view?.model
        model?.set
          position: position
          row:@row
        position + 1
      ),0

    handle_sortable_receive:(ev,ui)->
      LOG "DropAreaView","handle_sortable_receive"

    handle_sortable_update:(ev,ui)->
      LOG "DropAreaView","handle_sortable_update"
      view = ui.item.data DATA_VIEW
      if view?
        LOG "DropAreaView", "setRow #{@row}"
        view.model.set "row", @row
      else
        LOG "DropAreaView","view don't found"
      setTimeout (=>
        @reindex()        
      ), 0
      

    handle_droppable_drop:(ev,ui)->
      LOG "DropAreaView","handle_droppable_drop"
      view = ui.helper.data DATA_VIEW
      
      unless view?
        type = ui.draggable.data DATA_TYPE
        data = @options.service.getTemplateData(type)
        data.row = @row
        model = new DropAreaModel()
        model.set data
        @collection.push model
        view = new FormItemView
          el:ui.draggable
          model: model
          service: @options.service        
        view.render()
        ui.helper.data DATA_VIEW, view
      else
        view.$el = ui.draggable
        view.el = ui.draggable.get(0)
      ui.draggable.attr("class","")
      ui.draggable.data DATA_VIEW, view 

  DropAreaView