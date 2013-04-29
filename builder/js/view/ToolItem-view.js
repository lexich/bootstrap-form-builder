define(["jquery", "backbone", "underscore", "view/FormItem-view", "model/FormItem-model", "draggable"], function($, Backbone, _, FormItemView, FormItemModel) {
  var ToolItemView;

  ToolItemView = Backbone.View.extend({
    templatePath: "#ToolItemViewTemplate",
    template: "",
    placeholder: {},
    notvisual: false,
    /*
    @param data    -  function which return {Object} for underscore template
    */

    initialize: function() {
      var opts;

      this.notvisual = this.options.data.data.notvisual != null;
      if (this.notvisual) {
        opts = {
          connectToSortable: "[data-js-notvisual-drop]",
          scroll: false
        };
      } else {
        opts = {
          connectToSortable: "[data-drop-accept]:not([data-js-row-disable-drag]),[data-drop-accept-placeholder]"
        };
      }
      _.extend(opts, {
        appendTo: "body",
        opacity: 0.7,
        cursor: "pointer",
        cursorAt: {
          top: -1,
          left: -1
        },
        zIndex: 1500,
        helper: "clone",
        start: _.bind(this.handle_draggable_start, this),
        stop: _.bind(this.handle_draggable_stop, this)
      });
      this.$el.draggable(opts);
      return this.template = _.template($("" + this.templatePath).html(), this.options.data);
    },
    handle_draggable_start: function() {
      if (!this.notvisual) {
        $("[data-drop-accept-placeholder]").not("[data-ghost-row]").show();
      }
      return $("body").addClass("ui_draggableprocess");
    },
    handle_draggable_stop: function() {
      if (!this.notvisual) {
        $("[data-drop-accept-placeholder]").hide();
      }
      return $("body").removeClass("ui_draggableprocess");
    },
    render: function() {
      var data;

      data = this.options.service.getData(this.options.type);
      this.$el.html(this.template);
      this.$el.attr("data-" + DATA_TYPE, this.options.type);
      this.$el.addClass("ui_tools-" + this.options.type);
      data.$el.before(this.$el);
      return this;
    }
  });
  return ToolItemView;
});
