define [
  "jquery"
  "backbone"
  "underscore"
  "view/Fieldset-view"
  "model/Fieldset-model"
  "common/BackboneCustomView"
],($,Backbone,_,FieldsetView, FieldsetModel)->
  FormView = Backbone.CustomView.extend
    ###
    Variables Backbone.View
    ###
    events:
      "click [data-js-add-drop-area]":"event_clickAddFieldset"

    ###
    Variables Backbone.CustomView
    ###
    ChildType: FieldsetView
    templatePath:"#FormViewTemplate"
    itemsSelectors:
      placeholder:"[data-html-formloader]:first"
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
          view = @getOrAddFieldsetView(fieldset, models)
          view.reinitialize?()
          view.cid
        .value()

      _.each _.omit(@childrenViews,childrenCID),(view,cid)=>
        @removeChild view

    ###
    @overwrite Backbone.CustomView
    ###
    childrenConnect:(self,view)->
      $placeholder = self.getItem("placeholder")
      $placeholder.append view.$el
      $placeholder.append "<hr>"


    ###
    Find view by fieldset index or add New
    ###
    getOrAddFieldsetView:(fieldset, models)->
      models = [] unless models?
      filterViews = _.filter @childrenViews,(view)->
        view.model.get("fieldset") is fieldset

      if filterViews.length > 0
        view = filterViews[0]
      else
        view = @createChild
          service: @options.service
          models: models
          model: new FieldsetModel(fieldset:fieldset)
          collection: @collection
          accept:($el)->
            $el.hasClass "ui-draggable"
      view.models = models
      view

    ###

    ###
    event_clickAddFieldset:->
      fieldset = _.size( @getItem("fieldsets"))
      view = @getOrAddFieldsetView(fieldset)
      @render()

  FormView