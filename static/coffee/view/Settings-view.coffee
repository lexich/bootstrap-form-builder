define [
  "jquery"
  "backbone"
  "underscore"
  "common/Log"
  "spinner"
  "select2"
],($,Backbone,_,Log)->
  log = Log.getLogger("view/SettingsView")

  UI =
    select2:($el,options)->
      options = options ? {}
      options.closeOnSelect = true

      val = $el.data("value")
      unless val? then $el.data "value", $el.val()
      val = $el.data("value")

      if $el[0].tagName.toLowerCase() is "select" and options.data?
        bSelected = false
        opts = _.map options.data or [],(item)->
          if item.id is val
            bSelected = true
            selected = "selected"
          else selected = ""
          "<option #{selected} value='#{item.id}'>#{item.text}</option>"
        unless bSelected then opts.splice(0,0,"<option></option>")
        $el.html opts.join("")
        delete options.data

      if $el[0].tagName.toLowerCase() is "input"
        options.initSelection = ($el, callback)->
          value = $el.data("value")
          opt = $el.data("ui-data")
          $.ajax(
            url: opt.ajax.url
            data: {value}
          ).done (data)->
            callback data

      if options.ajax?
        _.extend options.ajax,
          data:(term, page)->
            q:"test"
          results:(data,page)->
            data

      if $el.is("select")
        delete options.multiple
        delete options.data

      $el.select2(options)
      #if (val? and val != "") then $el.select2 "val", val

      spinner:($el,options)-> $el.spinner(options ? {})

  SettingsView = Backbone.View.extend
    visibleMode:false
    activeView:null

    events:
      "click [data-html-settings-item] [data-js-save]":   "event_itemSave"
      "click [data-html-settings-item] [data-js-remove]": "event_itemRemove"
      "click [data-html-settings-item] [data-js-hide]":   "event_itemHide"
      "change [data-html-settings-loader] [data-js-itemaction*='change']":"event_itemAction"
      "click [data-html-settings-loader] [data-js-itemaction*='click']":"event_itemAction"

    initialize:->
      log.info "initialize"
      @$el.addClass "hide"
      _.bindAll this
      @listenTo @options.service, "editableView:set", @on_editableView_set
      @modalTemplates = _.reduce $("[data-#{@options.dataPostfixModalType}]"),(
        (memo,item)=>
          type = $(item).data(@options.dataPostfixModalType)
          if type? and type != ""
            memo[type] = $(item).html()
          memo
      ),{}

    getArea:-> $("[data-html-settings-loader]",@$el)

    setVisibleMode:(bValue)->
      log.info "setVisibleMode #{bValue}"
      @visibleMode = bValue
      $item = $("[data-html-settings]")
      $(document).off "mousedown", @handle_VisibleMode
      if bValue
        $item.removeClass "hide"
        setTimeout (=> $(document).on "mousedown", @handle_VisibleMode),0
      else
        $item.addClass "hide"
        $(".select2-drop").hide()
        @options.service.trigger "editableView:change"

    handle_VisibleMode:(e)->
      log.info "handle_VisibleMode"
      return if @__find @$el, e.target
      return if @activeView? and @__find @activeView.$el, e.target
      @setVisibleMode(false)

    render:->
      log.info "render"
      return unless (model = @activeView?.model)
      $body = @getArea()
      data = model.attributes
      $body.empty()
      if @activeView.viewname is "fieldset"
        $frag = $("<div>")
        config = model.get_template_config()
        pieces = _.map model.attributes, (v,k)=>
          item = config[k]
          if item? then @renderModalItemTemplate( item.type,
            title:item.title
            value:v
            name:k
            data:item.data
            actions:item.actions
          ) ? []

        $frag.html pieces.join("")
        $body.append $frag.children()
      else
        type = model.get("type")
        $body.append @renderForm(type, data)
      _.each $body.find("[data-ui]"),(el)=>
        uicomponent = $(el).data("ui")
        if UI[uicomponent]?
          data = $(el).data("ui-data")
          data = {} unless _.isObject(data)
          if data?.inject?
            _.each data.inject,(v,k)=>
              data[k] = _.result(this,v)
            delete data.inject
          UI[uicomponent]($(el), data)

      _.each $("[data-js-itemaction]"), (el)=>
        @update_itemactionState $(el)

    loadIds:->
      result = _.map @collection.models, (model)-> id:model.get("id"), text:model.get("name") + "##{model.get("id")}"
      result

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
            $input.val(value).data("value",value)
      else
        meta = @options.service.getTemplateMetaData(type)
        settingsTitle = @options.service.getDataSettingsTitle(type)
        dataListRef = @options.service.getDataList(type)
        content = _.map data, (v,k)=>
          itemType = meta[k] ? "hidden"
          title = settingsTitle[k] ? k
          opts =
            title:title
            name: k
            value: v
            data: _.result(dataListRef, k)
            actions:null

          if _.isObject(opts.data)
            if opts.data.inject?
              _.each opts.data.inject,(v,k)=>
                opts[k] = _.result(this,v)
              delete opts.data.inject

          tmpl = @renderModalItemTemplate itemType, opts
          tmpl
        $frag.html content.join("")
      $frag.children()

    renderModalItemTemplate:(type,options)->
      log.info "renderModalItemTemplate"
      if type is null or type is ""
        type = "input"
      templateHtml = @modalTemplates[type]
      result = if templateHtml? and templateHtml != "" then _.template templateHtml, options else ""
      if options.actions?
        itemActions = _.keys(options.actions).join(" ")
        itemActionData = JSON.stringify(options.actions ? {})
        attrText = "data-js-itemaction='#{itemActions}' data-js-itemaction-data='#{itemActionData}'"
        result = result.replace(/<(input|textarea|select)/,"<$1 #{attrText}")
      "<div data-html-itemation>#{result}</div>"

    update_itemactionState:($el)->
      data = $el.data("js-itemaction-data")
      _.each data ? {},(d,act)=>
        bAction = d.value == ($el.val() ? $el.data("value") ? $el.is(":checked"))
        bAction = !bAction if d.reverse
        if d.action is "visible"
          $target = @$el.find("[name='#{d.target}']")
          if bAction then $target.parents("[data-html-itemation]:first").show() else $target.parents("[data-html-itemation]:first").hide()
        else if d.action is "enabled"
          if bAction then $el.removeAttr("disabled") else $el.attr("disabled",true)

    on_editableView_set:(view)->
      log.info "on_editableView_set"
      @activeView = view
      if view?
        @render()
        @setVisibleMode(true)

    event_itemAction:(e)->
      @update_itemactionState $(e.target)

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
      @options.service.trigger "editableView:remove"
      @setVisibleMode(false)

    event_itemHide:->
      log.info "event_itemHide"
      @setVisibleMode(false)

    __find:($el,target)->
      log.info "__find"
      return false unless $el?
      if $el[0] == target
        return true
      else
        return true if $el.find($(target)).length > 0
      false

  SettingsView