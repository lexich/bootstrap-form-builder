define [
  "jquery"
  "backbone"
  "underscore"
  "view/Fieldset-view"
  "model/Fieldset-model"
  "common/BackboneCustomView"
  "jquery-ui/jquery.ui.droppable"
],($,Backbone,_,FieldsetView, FieldsetModel)->
  FormView = Backbone.CustomView.extend
    ###
    Variables Backbone.View
    ###
    className:"ui_formview"
    events:
      "customdragstart":"event_customstart"
      "customdragstop":"event_customdragstop"
    ###
    Variables Backbone.CustomView
    ###
    ChildType: FieldsetView
    templatePath:"#FormViewTemplate"
    itemsSelectors:
      loader:"[data-html-formloader]:first"
      fieldsets: "form  fieldset"

    ###
    @overwrite Backbone.View
    ###
    initialize:->
      @options.settings.connect "form:save", => @collection.updateAll()
      @collection.on "reset", _.bind(@on_collection_reset,this)

    ###
    bind to event 'reset' for current collection
    ###
    on_collection_reset:->
      @reinitialize()
      @render()

    ###
    @overwrite Backbone.CustomView
    ###
    reinitialize:->
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
      $loader = self.getItem("loader")
      $loader.append view.$el
      $loader.append "<hr>"

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
          model: new FieldsetModel(fieldset:fieldset)
          collection: @collection
          accept:($el)->
            $el.hasClass "ui-draggable"
      view

    event_customstart:->
      LOG "FormView","event_customstart"

    event_customdragstop:(e,data)->
      LOG "FormView", "event_customdragstop"




  FormView