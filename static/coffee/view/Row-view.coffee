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
    @overwrite Backbone.CustomView
    ###
    childrenConnect:(self,view)->
      view.$el.appendTo self?.getItem("area")

    ###
    @overwrite Backbone.CustomView
    ###
    reinitialize:->
      _.each @models, (model)=> @getOrAddChildTypeByModel(model).reinitialize()


    getOrAddChildTypeByModel:(model)->
      views = _.filter @childrenViews, (view, cid)->
        view.model = model
      if views.length > 0
        view = views[0]
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

    reindex:->
      LOG "RowView","reindex"
      _.reduce @getItem("areaChildren"), ((position,el)=>
        view = Backbone.CustomView::staticViewFromEl el
        model = view?.model
        model?.set {
          position: position
          row: @model.get "row"
          fieldset: @model.get "fieldset"
          direction: @model.get "direction"
        }, validate: true
        position + 1
      ),0

  RowView