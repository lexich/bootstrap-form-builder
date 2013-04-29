define(["jquery", "backbone", "underscore"], function($, Backbone, _) {
  var ModalView;

  ModalView = Backbone.View.extend({
    DEFAULT_MODAL_BODY: ".modal-body",
    className: "modal-wrapper",
    events: {
      "click *[data-js-close]": "event_close",
      "click *[data-js-save]": "event_save"
    },
    /*
    @param options
      - classModalBody - selector which find to update content
    */

    initialize: function() {
      this.$el.hide();
      this.$el.html("");
      this.$el.appendTo($("body"));
      return this.options.classModalBody = this.options.classModalBody || this.DEFAULT_MODAL_BODY;
    },
    /*
    @param options
      - preRender - callback which send 2 params $el and body to modify when view render
      - postSave - callback which send 2 params $el and body to modify when view catch event_save
    */

    show: function(options) {
      var _this = this;

      this.callback_preRender = function($el, $body) {
        return options != null ? options.preRender($el, $body) : void 0;
      };
      this.callback_postSave = function($el, $body) {
        return options != null ? options.postSave($el, $body) : void 0;
      };
      this.render();
      return this.$el.show();
    },
    hide: function() {
      return this.$el.hide();
    },
    render: function() {
      this.$el.css({
        width: $(window).width(),
        height: $(window).height(),
        top: 0,
        left: 0,
        position: "absolute"
      });
      return this.callback_preRender(this.$el, $(this.options.classModalBody, this.$el));
    },
    callback_preRender: function($el, $body) {},
    callback_postSave: function($el, $body) {},
    event_close: function() {
      return this.hide();
    },
    event_save: function() {
      this.hide();
      return this.callback_postSave(this.$el, $(this.options.classModalBody, this.$el));
    }
  });
  return ModalView;
});
