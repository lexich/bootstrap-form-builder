define [
  "jquery"
  "backbone"
  "underscore"
  "common/Log"
  "sortable"
  "common/BackboneCustomView"
],($,Backbone,_,Log)->
  log = Log.getLogger("view/NotVisualItem")
  NotVisualItem = Backbone.CustomView.extend

    SELECTED_CLASS:"ui_notvisual__item-active"

    className:"ui_notvisual__item"
    templatePath:"#NotVisualItemTemplate"

    wireEvents:
      "editableView:change":"on_editableView_change"
      "editableView:remove":"on_editableView_remove"

    bindWireEvents:->
      @__saveWireEvents = _.reduce @wireEvents or {}, ((save, callback,action)=>
        handler = _.bind(this[callback], this)
        @listenTo @options.service, action, handler
        save[action] = handler
        save),{}

    unbindWireEvents:->
      _.each @__saveWireEvents or {}, (handler, action)=>
        @stopListening @options.service, action, handler

    events:
      "click":"event_clickEditable"

    templateData:->
      templateHTML = @options.service.getTemplate(@model.get("type"))
      data = _.extend id: _.uniqueId("notvisual_"), @model.attributes
      content = _.template templateHTML, data
      {content,model:@model.attributes, cid:@cid}

    itemsSelectors:
      loader:"[data-js-notvisual-drop]"

    initialize:->
      log.info "initialize #{@cid}"
      @listenTo @model, "change", @on_model_change

    event_clickEditable:->
      log.info "event_clickEditable #{@cid}"
      if @options.service.setEditableView(this)
        @bindWireEvents()
        @$el.addClass(@SELECTED_CLASS)

    on_model_change:->
      @render()

    on_editableView_change:(view)->
      return if view is this
      @unbindWireEvents()
      @$el.removeClass(@SELECTED_CLASS)

    on_editableView_remove:->
      @unbindWireEvents()
      @remove()


  NotVisualItem