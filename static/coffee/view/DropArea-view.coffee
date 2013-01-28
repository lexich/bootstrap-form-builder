define [
  "jquery",
  "backbone",
  "underscore",
  "view/FormItem-view",
  "jquery-ui/jquery.ui.draggable",
  "jquery-ui/jquery.ui.droppable"
  "jquery-ui/jquery.ui.sortable"
],($,Backbone,_,FormItemView)->
  DropAreaView = Backbone.View.extend
    events:
      "click [data-js-close-area]":"event_close"
      "click [data-js-options-area]":"event_options"
    row:0
    formItemViews:[]
    initialize:->    
      @setRow @options.row
      $area = @getArea() 
      $area.droppable
        accept: @options.accept
        drop: _.bind(@handle_droppable_drop,this)
      $area.sortable
        axis: "y"
        connectWith:"[data-drop-accept]"
        receive:_.bind(@handle_sortable_receive,this)
        update:_.bind(@handle_sortable_update,this)
    
    setRow:(row)->
      models = @collection.where(row:@row)
      _.each models, (model)=>
        model.set "row",row, {silent:true}
      @row = row
      @$el.find("[data-html-row]").html(@row)

    event_close:(e)->
      _.each @$el.find("[data-drop-accept]").children(), (el)->
        view = $(el).data DATA_VIEW
        view?.remove()
      @options.formview?.removeDropArea this
      @remove()

    event_options:(e)->

    getArea:-> @$el.find("[data-drop-accept]")

    render:->
      $area = @getArea()
      $area.empty()
      models = @collection.where(row:@row)
      _.each models, (model)=>
        view = @getOrAddFormItemView(model)
        view.$el.appendTo $area


    getOrAddFormItemView:(model)->
      filterItem = _.filter @formItemViews, (view)->
        view.model is model
      if filterItem.length > 1
        filterItem[0]
      else      
        item = new FormItemView
          model: model
          service: @options.service
        @formItemViews.push item
        item

    async_reindex:->
      setTimeout (=>@reindex()), 0

    reindex:->
      LOG "DropAreaView","reindex"
      position = 0
      @formItemViews = []
      _.reduce @getArea().children(), ((position,el)=>
        view = $(el).data DATA_VIEW
        model = view?.model
        model?.set
          position: position
          row:@row
        @formItemViews.push view
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
      @async_reindex()

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
        ui.helper.data DATA_VIEW, view
      else
        view.$el = ui.draggable
        view.el = ui.draggable.get(0)
      ui.draggable.attr("class","")
      ui.draggable.data DATA_VIEW, view 

  DropAreaView