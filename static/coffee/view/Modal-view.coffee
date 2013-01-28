define [
  "jquery",
  "backbone",
  "underscore"
],($,Backbone,_)-> 
  ModalView = Backbone.View.extend
    DEFAULT_MODAL_BODY:".modal-body"
    events:
      "click *[data-js-close]":"event_close"
      "click *[data-js-save]":"event_save"

    initialize:->
      @$el.hide()
      @$el.html @options.html
      @$el.appendTo $("body")
      @options.classModalBody = @options.classModalBody || @DEFAULT_MODAL_BODY
      

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