define [
  "jquery",
  "backbone",
  "underscore",
  "view/FormItem-view",
  "model/FormItem-model"
  "jquery-ui/jquery.ui.draggable",
  "jquery-ui/jquery.ui.droppable"
  "jquery-ui/jquery.ui.sortable"
],($,Backbone,_,FormItemView,FormItemModel)->
  DropAreaView = Backbone.View.extend
    events:
      "click": "event_click"

    DEFAULT_AREA_SELECTOR: "[data-drop-accept]"
    DEFAULT_ROW_VIEW: "[data-html-row]"
    HOVER_CLASS: "hover-container"
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
      @model.on "change", _.bind(@on_changeModel,this)
      @model.on "change:direction", _.bind(@on_changeDirection,this)

    on_changeModel:(model)->
      @$el.html @options?.service?.renderFormViewElement model.toJSON()
      @initArea @get$Area()
      @reindex()
      @render()
      model.save()

    on_changeDirection:(model)->
      direction = model.get("direction")
      @$el.attr "data-direction", direction
      $children = @get$Area().children()
      return unless $children.length > 0

      if direction is "vertical"
        @$el.removeClass("form-horizontal")
        @get$Area().addClass("fluid-row")
        @setAxis("x")
        $("select, input, textarea",@$el).removeClass "span12"
      else if direction is FormItemModel::HORIZONTAL
        @setAxis("y")
        @$el.addClass("form-horizontal")
        $("select, input, textarea",@$el).addClass "span12"
        @get$Area().removeClass("fluid-row")

      models = @collection.smartSliceNormalize @row, "direction", direction
      _.each models,(model)=>
        model.set "direction",direction,{validation:true}

    get$Area:-> $(@DEFAULT_AREA_SELECTOR, @$el)

    initArea:($area)->
      if $area.data("droppable")
        $area.droppable("destroy")
      $area.droppable
        accept: @options.accept || ""
        drop: _.bind(@handle_droppable_drop,this)

      if $area.data("sortable")
        $area.sortable("destroy")
      $area.sortable
        placeholder: "ui_workarea__placeholder_sortable"
        connectWith: @DEFAULT_AREA_SELECTOR
        update:_.bind(@handle_sortable_update,this)
        start:_.bind(@handle_sortable_start,this)
      $area.disableSelection()


    render:->
      LOG "DropAreaView", "render"
      @get$Area().empty()
      models = @collection.where row: @model.get("row")
      _.each models, (model)=>
        view = @options?.service?.getOrAddFormItemView model
        if view?
                  view.$el.appendTo @get$Area()
                  view.render()

    bindSettings:(holder)->
      @options.service.bindSettingsContainer
        holder: holder
        data: @model.toJSON()
        removeContainer:  => @removeContainer()
        changePosition:   (val)=> @setDirection val
        hideContainer:    => @$el.removeClass @HOVER_CLASS
        saveContainer:
          (data)=> @model.set data, {validate:true}

    removeContainer:->
      _.each @get$Area().children(), (el)->
        view = $(el).data DATA_VIEW
        view?.remove()
      @options.removeDropArea? @model.get("row")
      @remove()

    ###
    @param axis {string|["x","y"]} - axis param for jqueri-ui sortable plugin
    @return {boolean|true,false} - return true if success
    ###
    setAxis:(axis)->
      if axis in ["x","y"]
        @get$Area().sortable "option", "axis", axis
        true
      else
        false

    setDirection:(direction)->
      @model.set "direction", direction, {validate:true}

    reindex:->
      LOG "DropAreaView","reindex"
      _.reduce @get$Area().children(), ((position,el)=>
        view = $(el).data DATA_VIEW
        model = view?.model
        model?.set {
          position: position
          row: @model.get "row"
          direction: @model.get("direction")
        }, validation: true
          
        position + 1
      ),0

    handle_sortable_start:(ev,ui)->
      LOG "DropAreaView", "handle_sortable_start"
      direction = @model.get("direction")
      if direction is FormItemModel::HORIZONTAL
        ui.placeholder.removeClass("row-fluid")
      else if direction is FormItemModel::VERTICAL
        ui.placeholder.addClass("row-fluid")

    handle_sortable_update:(ev,ui)->
      LOG "DropAreaView","handle_sortable_update"
      view = ui.item.data DATA_VIEW
      if view?
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
        model = new FormItemModel()
        model.set data
        @collection.push model
        view = @options.service.getOrAddFormItemView model, {el:ui.draggable}
        view.render()
        ui.helper.data DATA_VIEW, view
      else
        view.$el = ui.draggable
        view.el = ui.draggable.get(0)
      ui.draggable.attr("class","")
      ui.draggable.data DATA_VIEW, view
      @initArea @get$Area()

    event_click:->
      @bindSettings(true)



  DropAreaView