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
  "common/BackboneCustomView"
],($,Backbone,_,FormItemView,FormItemModel, DropAreaModel)->
  RowView = Backbone.CustomView.extend
    ###
    Constants
    ###
    HOVER_CLASS: "hover-container"

    ###
    Variables Backbone.View
    ###
    events: {}


    className:"ui_workarea__placeholder form-horizontal"

    ###
    Variables Backbone.CustomView
    ###
    templatePath:"#RowViewTemplate"
    ChildType:FormItemView
    itemsSelectorsCache:false
    itemsSelectors:
      area:"[data-drop-accept]"
      areaChildren:"[data-drop-accept] >"


    ###
    @overwrite Backbone.View
    ###
    initialize:->
      LOG "RowView","initialize"


    render:->
      Backbone.CustomView::render.apply this, arguments
      connector = @itemsSelectors.area
      @getItem("area").sortable
        helper:"original"
        tolerance:"pointer"
        dropOnEmpty:"true"
        connectWith: connector
        start:_.bind(@handle_sortable_start, this)
        stop: _.bind(@handle_sortable_stop, this)
        update: _.bind(@handle_sortable_update,this)

    ###
    @overwrite Backbone.CustomView
    ###
    reinitialize:->
      LOG "RowView","reinitialize"
      _.each @models, (model)=>
        view = @getOrAddChildTypeByModel(model)
        view.reinitialize()

    ###
    Handle to jQuery.UI.sortable - start
    ###
    handle_sortable_start:->
      LOG "RowView","handle_sortable_start"
      #@parentView?.handle_draggable_start()

    ###
    Handle to jQuery.UI.sortable - stop
    ###
    handle_sortable_stop:->
      LOG "RowView","handle_sortable_stop"

    ###
    Handle to jQuery.UI.sortable - update
    ###
    handle_sortable_update:(event,ui)->
      LOG "RowView","handle_sortable_update"
      #unless Backbone.CustomView::staticViewFromEl(ui.helper)
      #  @createChild
      #    model: @createFormItemModel()
      #    service: @options.service
      #@reindex()

    ###
    create new model FormItemModel
    @return FormItemModel
    ###
    createFormItemModel:(data)->
      LOG "RowView","createFormItemModel"
      data = _.extend data or {}, {row:@model.get("row"), fieldset:@model.get("fieldset")}
      model = new FormItemModel data
      @collection.add model
      @models.push model
      model

    ###
    reindex all items in current row
    ###
    reindex:->
      LOG "RowView","reindex"
      _.reduce @getItem("areaChildren"), ((position,el)=>
        if(view = Backbone.CustomView::staticViewFromEl el)
          view.model?.set {
             position
             row: @model.get "row"
             fieldset: @model.get "fieldset"
             direction: @model.get "direction"
          }, validate: true

        position + 1
      ),0

    ###
    @overwrite Backbone.CustomView
    ###
    childrenConnect:(self,view)->
      LOG "RowView","childrenConnect"
      view.$el.appendTo self?.getItem("area")


    getOrAddChildTypeByModel:(model)->
      views = _.filter @childrenViews, (view, cid)-> view.model == model

      if views.length > 0 then view = views[0]
      else
        view = @createChild
          model: model
          service:@options.service
      view

    changeDirection:(model)->
      direction = model.get("direction")
      @$el.attr "data-direction", direction
      $area = @getItem("area")
      $children = $area.children()
      return unless $children.length > 0

      models = @collection.smartSliceNormalize @model.get("row"), "direction", direction
      _.each models,(model)=>
        model.set "direction",direction,{validate:true}

      if direction is DropAreaModel::VERTICAL
        @$el.removeClass("form-horizontal")
        $area.addClass("row-fluid")
      else if direction is DropAreaModel::HORIZONTAL
        @$el.addClass("form-horizontal")
        $area.removeClass("row-fluid")

    bindSettings:(holder)->
      @options.service.bindSettingsContainer
        holder: holder
        data: @model.toJSON()
        changePosition:   (val)=> @setDirection val
        hideContainer:    => @$el.removeClass @HOVER_CLASS
        saveContainer:
          (data)=> @model.set data, {validate:true}


    setDirection:(direction)->
      @model.set "direction", direction, {validate:true}



  RowView