define [
  "jquery"
  "backbone"
  "underscore"
  "common/Log"
  "sortable"
  "common/BackboneCustomView"
  "common/BackboneWireMixin"
],($,Backbone,_,Log)->
  log = Log.getLogger("view/NotVisualItem")

  CustomView = do(
    __super__ = Backbone.CustomView,
    log = log
  )-> __super__.extend
    viewname:"notvisualitem"
    templatePath:"#NotVisualItemTemplate"

    templateData:->
      templateHTML = @options.service.getTemplate(@model.get("type"))
      data = _.extend id: _.uniqueId("notvisual_"), @model.attributes
      content = _.template templateHTML, data
      {content,model:@model.attributes, cid:@cid}

    itemsSelectors:
      loader:"[data-js-notvisual-drop]"


  NotVisualItem = do(
    __super__ = CustomView.extend Backbone.WireMixin,
    log = log
  )-> __super__.extend

    SELECTED_CLASS:"ui_notvisual__item-active"

    className:"ui_notvisual__item"

    wireEvents:
      "editableView:change":"on_editableView_change"
      "editableView:remove":"on_editableView_remove"

    events:
      "click":"event_clickEditable"

    initialize:->
      log.info "initialize #{@cid}"
      @listenTo @model, "change", @on_model_change

    remove:->
      log.info "remove #{@cid}"
      @unbindWireEvents()
      __super__::remove.apply this, arguments

    event_clickEditable:->
      log.info "event_clickEditable #{@cid}"
      if @options.service.setEditableView(this)
        @bindWireEvents @options.service, @wireEvents
        @$el.addClass(@SELECTED_CLASS)

    on_model_change:->
      log.info "on_model_change #{@cid}"
      @render()

    on_editableView_change:(view)->
      log.info "on_editableView_change #{@cid}"
      return if view is this
      @unbindWireEvents()
      @$el.removeClass(@SELECTED_CLASS)

    on_editableView_remove:->
      log.info "on_editableView_remove #{@cid}"
      @remove()


  NotVisualItem