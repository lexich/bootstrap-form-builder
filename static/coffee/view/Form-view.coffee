define [
  "jquery"
  "backbone"
  "underscore"
  "view/Fieldset-view"
  "model/Fieldset-model"
  "common/Log"

  "common/BackboneCustomView"
  "jquery-ui/jquery.ui.droppable"
],($,Backbone,_,FieldsetView, FieldsetModel, Log)->
  log = Log.getLogger("view/FormView")

  FormView = Backbone.CustomView.extend
    ###
    Variables Backbone.View
    ###

    className:"ui_formview"
    ###
    Variables Backbone.CustomView
    ###
    viewname:"form"
    ChildType: FieldsetView
    templatePath:"#FormViewTemplate"
    itemsSelectors:
      loader:"[data-html-formloader]:first"
      fieldsets: "form  fieldset"

    ###
    @overwrite Backbone.View
    ###
    initialize:->
      log.info "initialize #{@cid}"
      @collection.on "reset", _.bind(@on_collection_reset,this)

    ###
    bind to event 'reset' for current collection
    ###
    on_collection_reset:->
      log.info  "on_collection_reset #{@cid}"
      @reinitialize()
      @render()

    ###
    @overwrite Backbone.CustomView
    ###
    reindex:->
      log.info "reindex #{@cid}"
      _.reduce @getItem("fieldsets"), ((fieldset,el)=>
        if(view = Backbone.CustomView::staticViewFromEl el)
          view.model?.set
            fieldset: fieldset
            ,{validate: true}
          fieldset + 1
      ),0

    ###
    @overwrite Backbone.CustomView
    ###
    reinitialize:->
      log.info "reinitialize #{@cid}"
      childrenCID = _.chain(@collection.models)
        .groupBy (model)=>
          model.get("fieldset")
        .map (models,fieldset)=>
          fieldset = toInt fieldset
          view = @getOrAddFieldsetView(fieldset)
          view.reinitialize?()
          view.cid
        .value()

      _.each _.omit(@childrenViews,childrenCID),(view,cid)=>
        @removeChild view

    ###
    @overwrite Backbone.CustomView
    ###
    childrenConnect:(self,view)->
      log.info "childrenConnect #{@cid}"
      $loader = self.getItem("loader")
      $loader.append view.$el

    ###
    Find view by fieldset index or add New
    ###
    getOrAddFieldsetView:(fieldset)->
      filterViews = _.filter @childrenViews,(view)->
        view.model.get("fieldset") is fieldset

      if filterViews.length > 0
        view = filterViews[0]
      else
        view = @createChild
          service: @options.service
          model: @collection.getOrAddFieldsetModel(fieldset)
          collection: @collection
          accept:($el)->
            $el.hasClass "ui-draggable"
      view

    ###
    @overwrite Backbone.CustomView
    ###
    handle_create_new:(event,ui)->
      log.info "handle_create_new"
      view = Backbone.CustomView::staticViewFromEl(ui.item)
      fieldset = _.size(@childrenViews)
      if view? and view.viewname is "fieldset"
        @addChild view
        view.model.set "fieldset",fieldset,{validate:true}
      else
        view = @getOrAddFieldsetView fieldset
        view.handle_create_new(event,ui).reindex()
      this

  FormView