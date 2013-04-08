define [
   "jquery",
   "backbone",
   "underscore",
],($,Backbone,_)->
  SettingsView = Backbone.View.extend

    eventHolder:{}

    initialize:->
      @$el.addClass "hide"
      _.extend @eventHolder, Backbone.Events
      @bindEvents()

    _wrapTrigger:(action)->
      @eventHolder.trigger(action, @$el, @$body)

    _wrap: (action)->
      => @_wrapTrigger(action)

    connect:(action, callback)->
      @eventHolder.off(action)
      @eventHolder.on(action, callback)

    bindEvents:->
      events =
        "click [data-html-settings-item] [data-js-save]":         @_wrap("item:save")
        "click [data-html-settings-item] [data-js-remove]":       @_wrap("item:remove")
        "click [data-html-settings-item] [data-js-hide]":         @_wrap("item:hide")
      @events = _.extend @events or {}, events

    callback_preRender:->       @_wrapTrigger "render"
    callback_postSave:->        @_wrapTrigger "form:postsave"
    callback_remove:->          @_wrapTrigger "item:remove"
    callback_hide:->            @_wrapTrigger "item:hide"

    ###
    @param options
      - preRender - callback which send 2 params $el and body to modify when view render
      - postSave - callback which send 2 params $el and body to modify when view catch event_save
    ###
    show:(options)->
      return false if @holder and options.holder==null
      @callback_hide()
      @holder = options.holder
      @$el.removeClass "hide"
      @bindCallbacks options
      @$body = @$el.find("[data-html-settings-loader]")
      @render()
      true

    bindForm:(options)->
      @callback_saveForm = => options?.saveForm()

    bindContainer:(options)->
      return false if @holderContainer and options.holder==null
      @holderContainer = options.holder
      $("[data-js-position][value='#{options.data.direction}']", @$el).prop("checked","checked")
      $("[name='title']", @$el).val(options.data.title)

      @callback_removeContainer = -> options?.removeContainer()
      @callback_saveContainer = (data)-> options?.saveContainer data
      true

    bindCallbacks:(options)->
      @callback_preRender = ($el, $body)=> options?.preRender $el, $body
      @callback_postSave = ($el, $body)=> options?.postSave $el, $body
      @callback_remove = -> options?.remove()
      @callback_hide = -> options?.hide()

    releaseHolder:->
      @holder = null

    hide:->
      return false if @holder?
      @$el.addClass("hide")
      @callback_hide()
      true

    render:->
      @$body.empty()
      @callback_preRender @$el, @$body

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