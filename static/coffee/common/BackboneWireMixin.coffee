define [
  "backbone"
  "underscore"
],(Backbone, _)->
  Backbone.WireMixin =
    __saveWireEvents: {}
    ###
    bind wire events from wire convig, listen this.options.service
    ###
    bindWireEvents:(producer, wireEvents)->
      return unless producer?
      return unless wireEvents?
      _.extend @__saveWireEvents, _.reduce wireEvents, ((save, callback,action)=>
        handler = _.bind(this[callback], this)
        @listenTo producer, action, handler
        save[action] = [handler,producer]
        save),{}

    ###
    unbind wire events
    ###
    unbindWireEvents:->
      _.each @__saveWireEvents, _.bind @stopWireListen, this

    ###
    stop listen wire events
    @param pair - [handler, producer]
    @param action -
    ###
    stopWireListen:(pair, action)->
      [handler,producer] = pair
      @stopListening producer, action, handler
      if @__saveWireEvents[action]? then delete @__saveWireEvents[action]