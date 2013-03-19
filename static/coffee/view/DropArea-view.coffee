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
      "mouseenter": "event_mouseenter"
      "mouseleave": "event_mouseleave"

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
        placeholder: "ui_workarea__placeholder_sortable"
        connectWith: @DEFAULT_AREA_SELECTOR
        update:_.bind(@handle_sortable_update,this)
        start:_.bind(@handle_sortable_start,this)

      @$area.disableSelection()


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

    ###
    @param axis {string|["x","y"]} - axis param for jqueri-ui sortable plugin
    @return {boolean|true,false} - return true if success
    ###
    setAxis:(axis)->
      if axis in ["x","y"]
        @$area.sortable "option", "axis", axis
        true
      else
        false

    setDirection:(direction)->
      if direction is "vertical"
        @setFluentViewMode true
      else if direction is "horizontal"
        @setFluentViewMode false
      else
        return

    getDirection:->
      if @getFluentMode() then "vertical" else "horizontal"

    setFluentViewMode:(bMode)->
      @fluentMode = bMode
      @$el.attr "data-direction", @getDirection()
      $children = @$area.children()
      return unless $children.length > 0

      if bMode        
        @$el.removeClass("form-horizontal")
        @$area.addClass("fluid-row")
        @setAxis("x")
      else
        @setAxis("y")
        @$el.addClass("form-horizontal")
        @$area.removeClass("fluid-row")
      models = @collection.smartSliceNormalize @row, "direction", @getDirection()
      _.each models,(model)=>
        model.set "direction",@getDirection(),{
          validation:true
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

    handle_sortable_start:(ev,ui)->
      LOG "DropAreaView", "handle_sortable_start"
      if @getFluentMode()
        ui.placeholder.removeClass("row-fluid")
      else
        ui.placeholder.addClass("row-fluid")


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

    event_mouseenter:(e)->
      LOG "DropAreaView", "event_mouseenter"
      $("[data-js-show-tools]",@$el).addClass("ui_settings-show")

    event_mouseleave:(e)->
      LOG "DropAreaView", "event_mouseleave"
      $("[data-js-show-tools]", @$el).removeClass("ui_settings-show")

  DropAreaView