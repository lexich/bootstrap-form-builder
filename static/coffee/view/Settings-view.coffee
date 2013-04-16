define [
  "jquery"
  "backbone"
  "underscore"
  "common/Log"
],($,Backbone,_,Log)->
  log = Log.getLogger("view/SettingsView")

  SettingsView = Backbone.View.extend
    visibleMode:false
    activeView:null
    _bind__handle_VisibleMode:null

    events:
      "click [data-html-settings-item] [data-js-save]":   "event_itemSave"
      "click [data-html-settings-item] [data-js-remove]": "event_itemRemove"
      "click [data-html-settings-item] [data-js-hide]":   "event_itemHide"

    initialize:->
      log.info "initialize"
      @$el.addClass "hide"
      @bindServiceWire()
      @_bind__handle_VisibleMode = _.bind(@handle_VisibleMode,this)
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
      @options.service.eventWire.on "editableView:set", _.bind(@on_editableView_set,this)


    getArea:-> $("[data-html-settings-loader]",@$el)

    setVisibleMode:(bValue)->
      log.info "setVisibleMode #{bValue}"
      @visibleMode = bValue
      $item = $("[data-html-settings]")
      $(document).off "click", @_bind__handle_VisibleMode
      if bValue
        $item.removeClass "hide"
        setTimeout (=>$(document).on "click", @_bind__handle_VisibleMode),0
      else
        $item.addClass "hide"
        @options.service.eventWire.trigger "editableView:change"

    render:->
      log.info "render"
      return unless (model = @activeView?.model)
      $body = @getArea()
      type = model.get("type")
      data = model.attributes
      $body.empty()
      $body.append @renderForm(type, data)

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

    on_editableView_set:(view)->
      log.info "on_editableView_set"
      @activeView = view
      @render()
      @setVisibleMode(true)

    event_itemSave:->
      log.info "event_itemSave"
      service = @options.service
      return unless (model = @activeView?.model)
      data = service.parceModalItemData @getArea()
      model.set data, {validate:true}
      unless model.isValid()
        log.error model.validationError

    event_itemRemove:->
      log.info "event_itemRemove"
      @options.service.eventWire.trigger "editableView:remove"
      @setVisibleMode(false)

    event_itemHide:->
      log.info "event_itemHide"
      @setVisibleMode(false)

    handle_VisibleMode:(e)->
      unless @_$__find?
        @_$__find=($el,target)->
          return false unless $el?
          if $el[0] == target
            return true
          else
            target.id = _.uniqueId("_targetID") if target.id is ""
            return true if $el.find("##{target.id}").length > 0
          false

      return if @_$__find(@$el, e.target)
      return if @_$__find(@activeView?.$el, e.target)

      @setVisibleMode(false)

  SettingsView