define [
  "jquery"
  "backbone"
  "underscore"
  "common/Log"
  "view/NotVisualItem-view"

  "sortable"
  "common/BackboneCustomView"
],($,Backbone,_,Log, NotVisualItem)->
  log = Log.getLogger("view/NotVisual")

  CustomView = do(
    __super__ = Backbone.CustomView,
    log = log
  )-> __super__.extend
    viewname:"notvisual"
    ChildType:NotVisualItem
    templatePath:"#NotVisualViewTemplate"
    placeholderSelector:""
    itemsSelectors:
      loader:"[data-js-notvisual-drop]"
      loaderChildren:"[data-js-notvisual-drop] >"

    updateViewModes:->
      log.info "updateViewModes #{@cid}"
      $loader = @getItem("loader")

      $loader.data("sortable")?.destroy()
      $loader.sortable
        helper:"original"
        tolerance:"pointer"
        dropOnEmpty:true
        placeholder: "ui_notvisual__placeholder"
        start:_.bind(@handle_sortable_start, this)
        stop: _.bind(@handle_sortable_stop, this)
        update: _.bind(@handle_sortable_update,this)

    reinitialize:->
      log.info "reinitialize #{@cid}"
      childrenCID = _.map @collection.childCollection.notvisual.models,(model)=>
        view = @getOrAddViewByModel(model)
        view.reinitialize()
        view.cid
      _.each _.omit(@childrenViews,childrenCID),(view,cid)=>
        @removeChild view

    childrenViewsOrdered:->
      _.sortBy @childrenViews, (view,cid)-> view.model.get("position")

    childrenConnect:(parent,child)->
      log.info "childrenConnect #{@cid}"
      parent.getItem("loader").append(child.$el)

    reindex:->
      log.info "reindex #{@cid}"
      _.reduce @getItem("loaderChildren"), ((position,el)=>
        if(view = __super__::staticViewFromEl el)
          view.model?.set position:position
          position + 1
        else position
      ),0

    handle_sortable_update:(event,ui)->
      log.info "handle_sortable_update #{@cid}"
      view = __super__::staticViewFromEl(ui.item)
      if view?
        @reindex()
      else
        componentType = ui.item.data("componentType")
        data = @options.service.getTemplateData componentType
        model = @collection.addNotVisualModel data
        @createChild
          model: model
          collection:@collection
          service: @options.service
      @render()

  NotVisual = do(
    __super__ = CustomView,
    log = log
  )-> __super__.extend
    initialize:->
      log.info "initialize #{@cid}"
      @listenTo @collection, "reset", @on_collection_reset

    on_collection_reset:->
      log.info "on_collection_reset #{@cid}"
      @reinitialize()
      @render()

    getOrAddViewByModel:(model)->
      log.info "getOrAddViewByModel #{@cid}"
      filterViews = _.filter @childrenViews,(view)->
        view.model is model
      if filterViews.length > 0
        view = filterViews[0]
      else
        view = @createChild
          service: @options.service
          model: model
          collection: @collection
      view

  NotVisual