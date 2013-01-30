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

    DEFAULT_AREA_SELECTOR: "[data-drop-accept]"
    DEFAULT_ROW_VIEW: "[data-html-row]"
    row:0

    className:"ui_workarea__placeholder form-horizontal"
    ###
    @param options
      - row - {int|default 0}
      - accept {string|default ""}
      - removeDropArea {function} - function to remove this item from base container
      - fluentMode
      - service
        * renderFormViewElement
        * getOrAddFormItemView
        * getTemplateData
    ###
    initialize:->
      @row = @options.row if @options.row
      
      @$el.html @options?.service?.renderFormViewElement
        row: @row
      
      @$area = @$el.find @DEFAULT_AREA_SELECTOR
      @setFluentViewMode( @options.fluentMode or false )
      @$area.droppable
        accept: @options.accept || ""
        drop: _.bind(@handle_droppable_drop,this)

      @$area.sortable
        #axis:"y"
        connectWith: @DEFAULT_AREA_SELECTOR
        update:_.bind(@handle_sortable_update,this)

    render:->
      LOG "DropAreaView", "render"
      @$area.empty()
      models = @collection.where(row:@row)
      _.each models, (model)=>
        view = @options?.service?.getOrAddFormItemView model
        if view?
          view.$el.appendTo @$area
          view.render()
      if models.length > 0
        @setDirection models[0].get("direction")

    setRow:(row)->
      if @row != row
        @$el.find(@DEFAULT_ROW_VIEW).html("row: #{row}")
        @row = row
        @reindex()

    event_close:(e)->
      _.each @$area.children(), (el)->
        view = $(el).data DATA_VIEW
        view?.remove()
      @options.removeDropArea? @row
      @remove()

    getFluentMode:-> @fluentMode

    setDirection:(direction)->
      if direction is "vertical"
        @setFluentViewMode true
      else if direction is "horizontal"
        @setFluentViewMode false

    getDirection:->
      if @getFluentMode() then "vertical" else "horizontal"

    setFluentViewMode:(bMode)->
      @fluentMode = bMode
      $children = @$area.children()
      return unless $children.length > 0

      span = Math.floor(12.0/$children.length) - 1
      if bMode        
        @$el.removeClass("form-horizontal")
        @$area.addClass("fluid-row")
      else
        @$el.addClass("form-horizontal")
        @$area.removeClass("fluid-row")
      models = @collection.smartSliceNormalize @row, "direction", @getDirection()
      _.each models,(model)=>
        model.set "direction",@getDirection(),{
          validation:true
          silent:true
        }

    event_options:(e)->
      @setFluentViewMode not @getFluentMode()

    reindex:->
      LOG "DropAreaView","reindex"
      @setFluentViewMode @getFluentMode()
      _.reduce @$area.children(), ((position,el)=>
        view = $(el).data DATA_VIEW
        model = view?.model
        model?.set {
          position: position
          row:@row
          direction: @getDirection()
        }, validation: true
          
        position + 1
      ),0    

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