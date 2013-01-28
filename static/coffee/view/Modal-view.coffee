define [
  "jquery",
  "backbone",
  "underscore",
  "text!/static/templates/modelView.html"
],($,Backbone,_, templateHTML)->
  ModalView = Backbone.View.extend
    DEFAULT_MODAL_BODY:".modal-body"
    className:"modal-wrapper"
    events:
      "click *[data-js-close]":"event_close"
      "click *[data-js-save]":"event_save"

    ###
    @param options
      - classModalBody - selector which find to update content
    ###
    initialize:->
      @$el.hide()
      @$el.html templateHTML
      @$el.appendTo $("body")
      @options.classModalBody = @options.classModalBody || @DEFAULT_MODAL_BODY

    ###
    @param options
      - preRender - callback which send 2 params $el and body to modify when view render
      - postSave - callback which send 2 params $el and body to modify when view catch event_save
    ###
    show:(options)->
      @callback_preRender = ($el, $body)=> options?.preRender $el, $body
      @callback_postSave = ($el, $body)=> options?.postSave $el, $body
      @render()
      @$el.show()

    hide:->
      @$el.hide()

    render:->
      @$el.css
        width: $(window).width()
        height: $(window).height()
        top:0
        left:0
        position: "absolute"
      @callback_preRender @$el, $(@options.classModalBody, @$el)
      
    callback_preRender: ($el, $body)->
    callback_postSave: ($el, $body)->

    event_close:->
      @hide()

    event_save:->
      @hide()
      @callback_postSave @$el, $(@options.classModalBody, @$el)

  ModalView