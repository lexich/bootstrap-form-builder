define [
  "jquery"
  "backbone"
  "underscore"
  "common/Log"
],($,Backbone,_,Log)->
  log = Log.getLogger("view/SettingsView")

  SettingsView = Backbone.View.extend
    visibleMode:false
    handle_VisibleMode:->
    disableDocumentClick:->

    events:
      "click [data-html-settings-item] [data-js-save]":   "event_itemSave"
      "click [data-html-settings-item] [data-js-remove]": "event_itemRemove"
      "click [data-html-settings-item] [data-js-hide]":   "event_itemHide"

    initialize:->
      log.info "initialize"
      @$el.addClass "hide"
      @bindServiceWire()
      @handle_VisibleMode = (e)=>
        if e.target.id is "" then e.target.id = _.uniqueId("_targetID")
        if @$el.find("##{e.target.id}").length is 0
          @setVisibleMode(false)

      @modalTemplates = _.reduce $("[data-#{@options.dataPostfixModalType}]"),(
        (memo,item)=>
          type = $(item).data(@options.dataPostfixModalType)
          if type? and type != ""
            memo[type] = $(item).html()
          memo
      ),{}

    bindServiceWire:()->
      log.info "bindServiceWire"
      return unless @options.service?
      @options.service.eventWire.on "editableModel:set", _.bind(@on_editableModel_set,this)


    getArea:-> $("[data-html-settings-loader]",@$el)

    setVisibleMode:(bValue)->
      log.info "setVisibleMode #{bValue}"
      @visibleMode = bValue
      $item = $("[data-html-settings]")
      $(document).off "click", @handle_VisibleMode
      if bValue
        $item.removeClass "hide"
        setTimeout (=>$(document).on "click", @handle_VisibleMode),0
      else
        $item.addClass "hide"
        @options.service.eventWire.trigger "editableModel:change"

    render:->
      log.info "render"
      service = @options.service
      return unless (model = service.getEditableModel())
      $body = @getArea()
      type = model.get("type")
      data = model.attributes
      $body.empty()
      $body.append @renderForm(type, data)
      @setVisibleMode(true)


    renderForm:( type, data)->
      log.info "renderForm"
      $frag = $("<div>")
      $item = $("[data-ui-jsrender-modal-template='#{type}']:first")
      if $item.length is 1
        $frag.html $item.html()
        _.each $("input,select,textarea",$frag), (input)->
          $input = $(input)
          type = $input.attr("name")
          value = data[type]
          unless _.isUndefined(value)
            $input.val(value)
      else
        meta = @options.service.getTemplateMetaData(type)
        content = _.map data, (v,k)=>
          itemType = meta[k] ? "hidden"
          opts =
            name: k
            value: v
            data: @options.service.getItemFormTypes()
          tmpl = @renderModalItemTemplate itemType, opts
          tmpl
        $frag.html content.join("")
      $frag.children()

    renderModalItemTemplate:(type,data)->
      log.info "renderModalItemTemplate"
      if type is null or type is ""
        type = "input"
      templateHtml = @modalTemplates[type]
      if templateHtml? and templateHtml != ""
        _.template templateHtml, data
      else
        ""

    on_editableModel_set:->
      log.info "on_editableModel_update"
      @render()

    event_itemSave:->
      log.info "event_itemSave"
      service = @options.service
      return unless (model = service.getEditableModel())
      data = service.parceModalItemData @getArea()
      model.set data, {validate:true}
      if model.isValid()
        log.error model.validationError

    event_itemRemove:->
      log.info "event_itemRemove"
      @options.service.eventWire.trigger "editableModel:remove"
      @setVisibleMode(false)

    event_itemHide:->
      log.info "event_itemHide"
      @setVisibleMode(false)

  SettingsView