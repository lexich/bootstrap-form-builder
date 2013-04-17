define [
  "jquery"
  "backbone"
  "underscore"
  "common/Log"
  "view/NotVisualItem-view"

  "sortable"
  "common/BackboneCustomView"
],($,Backbone,_,Log, NotVisualItem,NotVisualModel)->
  log = Log.getLogger("view/NotVisual")
  NotVisual = Backbone.CustomView.extend
    ChildType:NotVisualItem
    templatePath:"#NotVisualViewTemplate"
    itemsSelectors:
      loader:"[data-js-notvisual-drop]"
      loaderChildren:"[data-js-notvisual-drop] >"

    initialize:->
      log.info "initialize #{@cid}"
      @listenTo @collection, "reset", @on_collection_reset

    updateViewModes:->
      log.info "updateViewModes #{@cid}"
      $loader = @getItem("loader")

      if $loader.data("sortable")?
        $loader.sortable "destroy"

      $loader.sortable
        helper:"original"
        tolerance:"pointer"
        dropOnEmpty:true
        placeholder: "ui_notvisual__placeholder"
        start:_.bind(@handle_sortable_start, this)
        stop: _.bind(@handle_sortable_stop, this)
        update: _.bind(@handle_sortable_update,this)

    ###
    @overwrite Backbone.CustomView
    ###
    reinitialize:->
      log.info "reinitialize #{@cid}"
      childrenCID = _.map @collection.notVisualCollection.models,(model)=>
        view = @getOrAddViewByModel(model)
        view.reinitialize()
        view.cid

      _.each _.omit(@childrenViews,childrenCID),(view,cid)=>
        @removeChild view

    getOrAddViewByModel:(model)->
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

    childrenViewsOrdered:->
      _.sortBy @childrenViews, (view,cid)-> view.model.get("position")

    childrenConnect:(parent,child)->
      parent.getItem("loader").append(child.$el)

    on_collection_reset:->
      log.info "on_collection_reset #{@cid}"
      @reinitialize()
      @render()

    reindex:->
      _.reduce @getItem("loaderChildren"), ((position,el)=>
        if(view = Backbone.CustomView::staticViewFromEl el)
          view.model?.set position:position
          position + 1
        else position
      ),0

    handle_sortable_update:(event,ui)->
      log.info "handle_sortable_update #{@cid}"
      view = Backbone.CustomView::staticViewFromEl(ui.item)
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


  NotVisual