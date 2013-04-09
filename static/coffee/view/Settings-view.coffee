define [
  "jquery"
  "backbone"
  "underscore"
  "common/Log"
],($,Backbone,_,Log)->
  log = Log.getLogger("view/SettingsView")

  SettingsView = Backbone.View.extend

    events:
      "click [data-html-settings-item] [data-js-save]":   "event_itemSave"
      "click [data-html-settings-item] [data-js-remove]": "event_itemRemove"
      "click [data-html-settings-item] [data-js-hide]":   "event_itemHide"


    event_itemRemove:->
      @options.service.eventWire.trigger "editableModel:remove"
      @setVisibleMode(false)

    event_itemHide:->
      @setVisibleMode(false)

    initialize:->
      log.info "initialize"
      @$el.addClass "hide"
      @bindServiceWire()

    bindServiceWire:()->
      log.info "bindServiceWire"
      return unless @options.service?
      @options.service.eventWire.on "editableModel:set", _.bind(@on_editableModel_set,this)

    on_editableModel_set:->
      log.info "on_editableModel_update"
      @render()

    getArea:-> $("[data-html-settings-loader]",@$el)

    render:->
      log.info "render"
      service = @options.service
      return unless (model = service.getEditableModel())
      $body = @getArea()
      type = model.get("type")
      data = model.attributes
      $item = service.renderSettingsForm(type, data)

      if $item.length is 1
        $body.empty()
        $item.appendTo $body
        $item.show()
      else
        meta = service.getTemplateMetaData(type)
        content = _.map data, (v,k)->
          itemType = meta[k] or ""
          opts =
            name: k
            value: v
            data: service.getItemFormTypes()
          service.renderModalItemTemplate itemType, opts

        $body.html content.join("")
      @setVisibleMode(true)


    event_itemSave:->
      log.info "event_itemSave"
      service = @options.service
      return unless (model = service.getEditableModel())
      data = service.parceModalItemData @getArea()
      model.set data

    setVisibleMode:(bValue)->
      $item = $("[data-html-settings]")
      if bValue
        $item.removeClass "hide"
      else
        $item.addClass "hide"
        @options.service.eventWire.trigger "editableModel:change"

    ###
    @param options
      - preRender - callback which send 2 params $el and body to modify when view render
      - postSave - callback which send 2 params $el and body to modify when view catch event_save
    ###
    show:(options)->
      log.info "show"
      return false if @holder and options.holder==null
      @setItemModel options.model
      @callback_hide()
      if options.service then @service = options.service
      @holder = options.holder
      @$el.removeClass "hide"
      @bindCallbacks options
      @$body = @$el.find("[data-html-settings-loader]")
      @render()
      true

    bindForm:(options)->
      log.info "bindform"
      @callback_saveForm = => options?.saveForm()

    bindContainer:(options)->
      log.info "bindContainer"
      return false if @holderContainer and options.holder==null
      @holderContainer = options.holder
      $("[data-js-position][value='#{options.data.direction}']", @$el).prop("checked","checked")
      $("[name='title']", @$el).val(options.data.title)

      @callback_removeContainer = -> options?.removeContainer()
      @callback_saveContainer = (data)-> options?.saveContainer data
      true

    bindCallbacks:(options)->
      log.info "bindCallbacks"
      @callback_preRender = ($el, $body)=> options?.preRender $el, $body
      @callback_postSave = ($el, $body)=> options?.postSave $el, $body
      @callback_remove = -> options?.remove()
      @callback_hide = -> options?.hide()

    releaseHolder:->
      log.info "releaseHolder"
      @holder = null

    hide:->
      log.info "hide"
      return false if @holder?
      @$el.addClass("hide")
      @callback_hide()
      true

    event_saveItem:->
      @callback_postSave @$el, @$body

    event_removeItem:->
      @callback_remove()
      @releaseHolder()
      @hide()

    event_hide:->
      @releaseHolder()
      @hide()

    event_removeContainer:(e)->
      @callback_removeContainer()

    event_changePosition:(e)->
      @callback_changePosition $(e.target).val()

    event_saveContainer:(e)->
      selector = "input[type='radio']:checked,input[type!='radio'], select, textarea"
      $items = $("[data-html-settings-container]:first").find(selector)
      data = _.reduce $items,(
        (memo,item)->
          memo[$(item).attr("name")] = $(item).val()
          memo
      ),{}
      @callback_saveContainer(data)

    event_submitForm:->
      @callback_saveForm()

  SettingsView