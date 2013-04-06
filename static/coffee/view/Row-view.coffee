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
    DISABLE_DRAG: "data-js-row-disable-drag"
    ###
    Variables Backbone.View
    ###
    events:
      "click [data-js-row-disable]":"event_disable"
      "click [data-js-row-position]":"event_position"


    className:"ui_row form-horizontal"

    ###
    Variables Backbone.CustomView
    ###
    viewname:"row"
    templatePath:"#RowViewTemplate"
    ChildType:FormItemView
    itemsSelectorsCache:false
    itemsSelectors:
      area:"[data-drop-accept]"
      areaChildren:"[data-drop-accept] >"

    initialize:->
      @model.on "change", _.bind(@on_model_change,this)

    templateData:->
      _.extend @model.toJSON(),cid:@cid

    ###
    @overwrite Backbone.View
    ###
    render:->
      LOG "RowView","render #{@cid}"
      if(sortable = @getItem("area").data("sortable"))
        sortable.destroy()

      Backbone.CustomView::render.apply this, arguments

      @getItem("area").sortable
        helper:"original"
        tolerance:"pointer"
        handle:"[data-js-formitem-move]"
        dropOnEmpty:"true"
        placeholder:"ui_formitem__placeholder"
        connectWith: "[data-drop-accept]:not([#{@DISABLE_DRAG}]),[data-drop-accept-placeholder]"
        start:_.bind(@handle_sortable_start, this)
        stop: _.bind(@handle_sortable_stop, this)
        update: _.bind(@handle_sortable_update,this)

      bVertical = @model.get('position') == "vertical"
      @setVertical bVertical


    on_model_change:(model,options)->
      changed = _.pick model.changed, _.keys(model.defaults)
      _.each @childrenViews,(view,cid)->
        #silent mode freeze changing beause render call
        view.model.set changed,{validate:true}


    event_disable:(e)->
      @_disable = false unless @_disable?
      @_disable = !@_disable
      $(e.target).text if @_disable then "Disabled" else "Enabled"
      @setDisable @_disable

    event_position:(e)->
      value = if @model.get('position') == 'vertical' then "horizontal" else "vertical"
      @model.set "position", value,{validate:true}


    setVertical:(flag)->
      if flag
        @getItem("areaChildren").addClass("span4")
        @$el.removeClass "form-horizontal"
      else
        @getItem("areaChildren").removeClass("span4")
        @$el.addClass "form-horizontal"

    setDisable:(flag)->
      flag = true unless flag?
      $area = @getItem("area")
      if flag
        $area.attr(@DISABLE_DRAG,"")
      else
        $area.removeAttr(@DISABLE_DRAG)

    ###
    @overwrite Backbone.CustomView
    ###
    childrenViewsOrdered:->
      _.sortBy @childrenViews, (view,cid)-> view.model.get("position")


    ###
    @overwrite Backbone.CustomView
    ###
    reinitialize:->
      LOG "RowView","reinitialize"
      models = @collection.getRow @model.get("fieldset"), @model.get("row")
      _.each models, (model)=>
        view = @getOrAddChildTypeByModel(model)
        view.reinitialize()

    handle_create_new:(event,ui)->
      LOG "RowView","handle_create_new"
      componentType = $(ui.item).data("componentType")
      data = @options.service.getTemplateData(componentType)
      formItemView = @createChild
        model: @createFormItemModel(data)
        service: @options.service
      this

    ###
    Handle to jQuery.UI.sortable - update
    ###
    handle_sortable_update:(event,ui)->
      LOG "RowView","handle_sortable_update #{@cid}"
      formItemView = Backbone.CustomView::staticViewFromEl(ui.item)
      if ui.sender?
        LOG "RowView","handle_sortable_update #{@cid} ui.sender != null"
        #Если View найден, создаем дочерний
        if formItemView?
          parentView = formItemView.parentView
          #Если произошло перемещение между RowView, устанавливаем текуший
          if parentView != this
            formItemView.setParent this
            @reindex()
      unless formItemView?
        componentType = $(ui.item).data("componentType")
        data = @options.service.getTemplateData(componentType)
        formItemView = @createChild
          model: @createFormItemModel(data)
          service: @options.service
        ui.item.replaceWith formItemView.$el
        @reindex()
        @render()

    ###
    create new model FormItemModel
    @return FormItemModel
    ###
    createFormItemModel:(data)->
      LOG "RowView","createFormItemModel #{@cid}"
      data = _.extend data or {}, {row:@model.get("row"), fieldset:@model.get("fieldset")}
      model = new FormItemModel data
      @collection.add model
      model

    ###
    reindex all items in current row
    ###
    reindex:->
      LOG "RowView","reindex #{@cid}"
      _.reduce @getItem("areaChildren"), ((position,el)=>
        if(view = Backbone.CustomView::staticViewFromEl el)
          view.model?.set {
             position
             row: @model.get "row"
             fieldset: @model.get "fieldset"
             direction: @model.get "direction"
          }, { validate: true }

        position + 1
      ),0

    ###
    @overwrite Backbone.CustomView
    ###
    childrenConnect:(self,view)->
      LOG "RowView","childrenConnect #{@cid}"
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