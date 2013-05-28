define [
  "jquery"
  "backbone"
  "underscore"
  "common/Log"
  "spinner"
  "select2"
],($,Backbone,_,Log)->
  log = Log.getLogger("view/SettingsView")

  SettingsView = Backbone.View.extend
    visibleMode:false
    activeView:null

    events:
      "click [data-html-settings-item] [data-js-save]":   "event_itemSave"
      "click [data-html-settings-item] [data-js-remove]": "event_itemRemove"
      "click [data-html-settings-item] [data-js-hide]":   "event_itemHide"

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

    ui:
      select2:($el,options)->
        options = options ? {}
        options.closeOnSelect = true

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
        $el.select2(options)

      spinner:($el,options)-> $el.spinner(options ? {})

    render:->
      log.info "render"
      return unless (model = @activeView?.model)
      $body = @getArea()
      type = model.get("type")
      data = model.attributes
      $body.empty()
      $body.append @renderForm(type, data)
      _.each $body.find("[data-ui]"),(el)=>
        uicomponent = $(el).data("ui")
        if @ui[uicomponent]?
          data = $(el).data("ui-data")
          if data?.inject?
            _.each data.inject,(v,k)=>
              data[k] = _.result(this,v)
            delete data.inject
          @ui[uicomponent]($(el), data)

    loadIds:-> _.map @collection.models, (model)-> id:model.get("id"), text:model.get("name") + "##{model.get("id")}"

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
          dataList = _.result(dataListRef, k)
          opts =
            title:title
            name: k
            value: v
            data: dataList
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
      if view?
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