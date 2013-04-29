define(["backbone", "underscore"], function(Backbone, _) {
  return Backbone.WireMixin = {
    __saveWireEvents: {},
    /*
    bind wire events from wire convig, listen this.options.service
    */

    bindWireEvents: function(producer, wireEvents) {
      var _this = this;

      if (producer == null) {
        return;
      }
      if (wireEvents == null) {
        return;
      }
      return _.extend(this.__saveWireEvents, _.reduce(wireEvents, (function(save, callback, action) {
        var handler;

        handler = _.bind(_this[callback], _this);
        _this.listenTo(producer, action, handler);
        save[action] = [handler, producer];
        return save;
      }), {}));
    },
    /*
    unbind wire events
    */

    unbindWireEvents: function() {
      return _.each(this.__saveWireEvents, _.bind(this.stopWireListen, this));
    },
    /*
    stop listen wire events
    @param pair - [handler, producer]
    @param action -
    */

    stopWireListen: function(pair, action) {
      var handler, producer;

      handler = pair[0], producer = pair[1];
      this.stopListening(producer, action, handler);
      if (this.__saveWireEvents[action] != null) {
        return delete this.__saveWireEvents[action];
      }
    }
  };
});
