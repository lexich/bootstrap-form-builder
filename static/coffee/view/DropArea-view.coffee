define [
  "jquery",
  "backbone",
  "underscore",
  "view/FormItem-view",
  "model/FormItem-model"
  "model/DropArea-model"
  "jquery-ui/jquery.ui.draggable",
  "jquery-ui/jquery.ui.droppable"
  "jquery-ui/jquery.ui.sortable"
],($,Backbone,_,FormItemView,FormItemModel, DropAreaModel)->
  DropAreaView = Backbone.View.extend
    events:
      "click": "event_click"

    DEFAULT_AREA_SELECTOR: "[data-drop-accept]"
    DEFAULT_ROW_VIEW: "[data-html-row]"
    HOVER_CLASS: "hover-container"

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

    on_changeModel:(model)->
      @$el.html @options?.service?.renderFormViewElement model.toJSON()
      @reindex()
      @render()
      @initArea @get$Area()
      @changeDirection model
      model.save()

    changeDirection:(model)->
      direction = model.get("direction")
      @$el.attr "data-direction", direction
      $area = @get$Area()
      $children = $area.children()
      return unless $children.length > 0

      if direction is DropAreaModel::VERTICAL
        @$el.removeClass("form-horizontal")
        $area.addClass("fluid-row")
        @setAxis("x")
        $("select, input, textarea",@$el).removeClass "span12"
      else if direction is DropAreaModel::HORIZONTAL
        @setAxis("y")
        @$el.addClass("form-horizontal")
        $("select, input, textarea",@$el).addClass "span12"
        @get$Area().removeClass("fluid-row")

      models = @collection.smartSliceNormalize @model.get("row"), "direction", direction
      _.each models,(model)=>
        model.set "direction",direction,{validation:true}

    get$Area:-> $(@DEFAULT_AREA_SELECTOR, @$el)

    ###
    Apply to $area jQuery.UI plugins
    @param $area
    ###
    initArea:($area)->
      #Reinitialize droppable
      if $area.data("droppable")
        $area.droppable("destroy")
      $area.droppable
        accept: @options.accept || ""
        drop: _.bind(@handle_droppable_drop,this)

      #Reinitialize sortable
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
        #@get$Area().sortable "option", "axis", axis
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
      #if direction is DropAreaModel::HORIZONTAL
      #  ui.placeholder.removeClass("row-fluid")
      #else if direction is DropAreaModel::VERTICAL
      #  ui.placeholder.addClass("row-fluid")

    handle_sortable_update:(ev,ui)->
      LOG "DropAreaView","handle_sortable_update"
      view = ui.item.data DATA_VIEW
      view?.model?.set "row", @model.get("row"), {validate:true}
      setTimeout (=>
        @reindex()
      ), 0
      @initArea @get$Area()
      @changeDirection @model

    handle_droppable_drop:(ev,ui)->
      LOG "DropAreaView","handle_droppable_drop"
      view = ui.helper.data DATA_VIEW

      unless view?
        type = ui.draggable.data DATA_TYPE
        data = @options.service.getTemplateData(type)
        data.row = @model.get "row"
        model = new FormItemModel()
        model.set data
        @collection.push model
        view = @options.service.getOrAddFormItemView model, {
          el:ui.draggable
        }
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