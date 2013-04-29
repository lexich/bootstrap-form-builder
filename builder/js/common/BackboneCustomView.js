define(["jquery", "underscore", "backbone", "common/Log"], function($, _, Backbone, Log) {
  var $bufferDocumentFragment, log, __super__;

  log = Log.getLogger("common/CustomView");
  __super__ = Backbone.View;
  $bufferDocumentFragment = $(document.createDocumentFragment());
  Backbone.CustomView = Backbone.View.extend({
    BIND_VIEW: "_$$CustomViewBinder",
    dragActive: false,
    ChildType: Backbone.CustomView,
    itemsSelectors: {},
    viewname: null,
    /*
    @constructor
    @param options - arguments
    */

    constructor: function(options) {
      if (this.viewname == null) {
        throw "Need this.viewname attribute";
      }
      this.configureOptions.apply(this, arguments);
      log.info("constructor viewname:" + this.viewname);
      Backbone.View.call(this, options);
      this.$el.data(Backbone.CustomView.prototype.BIND_VIEW, this);
      return this;
    },
    /*
    configure options after create instance of this View
    */

    configureOptions: function(options) {
      var mixin;

      mixin = {
        templatePath: null,
        templateData: function() {
          var _ref, _ref1;

          return (_ref = (_ref1 = this.model) != null ? _ref1.toJSON() : void 0) != null ? _ref : {};
        },
        placeholderSelector: "[data-drop-accept-placeholder]",
        parentView: null,
        childrenViews: {}
      };
      options = _.pick(options || {}, _.keys(mixin));
      _.extend(this, options);
      return _.defaults(this, mixin);
    },
    /*
    Handler connect this view with children views
    @param parent - pointer to this view
    @param child - child view
    */

    childrenConnect: function(parent, child) {},
    /*
    Helper to extract view frim DOM element
    */

    staticViewFromEl: function(el) {
      return $(el).data(Backbone.CustomView.prototype.BIND_VIEW);
    },
    /*
    Handler for reinit current conmonent, usualy change children state
    need overwrite in children Views prototype
    */

    reinitialize: function() {},
    /*
    Return html template of current view, from DOM document
    where this.teplatePath pointer to id of element
    <script id="{this.teplatePath}" type="text/template">TEMPLATE</script>
    @return {string} html teplate
    */

    _getTemplateHtml: function() {
      var tmpl, _ref;

      if ((this._getTemplateHtml_Cache != null) && this._getTemplateHtml_Cache !== "") {
        return this._getTemplateHtml_Cache;
      }
      if (this.templatePath == null) {
        return;
      }
      tmpl = this.templatePath.trim();
      this._getTemplateHtml_Cache = $("" + tmpl + "[type='text/template']:first").html();
      return (_ref = this._getTemplateHtml_Cache) != null ? _ref : "";
    },
    /*
    Get inner DOM el, where name if key of itemsSelectors dictionary
    @return {DOM} inner DOM element
    */

    getItem: function(name) {
      var selector;

      selector = this.itemsSelectors[name];
      if (selector != null) {
        return $(selector, this.$el);
      }
    },
    /*
    Helper for order children views, for overwriting in children View prototypes
    @return ordered children views
    */

    childrenViewsOrdered: function() {
      return _.values(this.childrenViews);
    },
    /*
    Handler for create new children view, using jQuery.ui drag & drop mechanism
    */

    handle_create_new: function(event, ui) {
      return this;
    },
    /*
    Method for init external placeholder for drag & drop
    @return placeholder
    */

    __initPlaceholder: function() {
      var $placeholder,
        _this = this;

      log.info("__initPlaceholder");
      $placeholder = $("> [data-drop-accept-placeholder]", this.$el);
      if (_.isUndefined($placeholder.data("sortable"))) {
        $placeholder.sortable({
          helper: "original",
          tolerance: "pointer",
          dropOnEmpty: "true",
          placeholder: "ui_formitem__placeholder span3",
          update: function(event, ui) {
            var view;

            view = _this.handle_create_new(event, ui);
            view.render();
            return view.reindex();
          },
          activate: function(event, ui) {
            _this.dragActive = true;
            return true;
          },
          deactivate: function(event, ui) {
            _this.dragActive = false;
            return true;
          },
          over: function(event, ui) {
            if ($(this).is("[data-drop-accept-placeholder='fieldset']")) {
              $("[data-ghost-row]").hide();
              $(this).sortable("refreshPositions");
            }
            return true;
          }
        });
      }
      return $placeholder;
    },
    /*
    Overwrite Backbone.View
    */

    render: function() {
      var data, html, htmlTemplate, result,
        _this = this;

      log.info("render " + this.viewname + ":" + this.cid);
      $bufferDocumentFragment.append(this.$el.children());
      result = __super__.prototype.render.apply(this, arguments);
      htmlTemplate = this._getTemplateHtml();
      data = _.result(this, "templateData");
      html = _.template(htmlTemplate, data);
      this.$el.html(html);
      this.__initPlaceholder();
      _.each(this.childrenViewsOrdered(), function(view) {
        _this.childrenConnect(_this, view);
        return view.render();
      });
      this.updateViewModes();
      this.$el.find("select,input,textarea").focus(function() {
        return $(this).blur();
      });
      return result;
    },
    /*
    Helper for reinder children components
    */

    reindex: function() {},
    /*
    Helper for update view
    */

    updateViewModes: function() {},
    /*
    jQuery.ui sortable start handler
    */

    handle_sortable_start: function() {
      $(this.placeholderSelector).show();
      return $("body").addClass("ui_draggableprocess");
    },
    /*
    jQuery.ui sortable start handler
    */

    handle_sortable_stop: function(event, ui) {
      $(this.placeholderSelector).hide();
      $("body").removeClass("ui_draggableprocess");
      return this.reindex();
    },
    /*
    helper for check model
    */

    checkModel: function(log, model) {
      if (!model.isValid()) {
        log.error(model.validationError);
        return false;
      } else {
        return true;
      }
    },
    /*
    Overwrite Backbone.View
    */

    remove: function() {
      var _ref, _ref1, _ref2,
        _this = this;

      log.info("remove " + this.cid);
      if (this.model != null) {
        if ((_ref = this.collection) != null) {
          _ref.remove(this.model);
        }
      }
      if ((_ref1 = this.parentView) != null) {
        _ref1.removeChild(this);
      }
      if ((_ref2 = this.parentView) != null) {
        _ref2.updateViewModes();
      }
      _.each(this.childrenViews, function(view, k) {
        _this.removeChild(view);
        return view.remove();
      });
      return __super__.prototype.remove.apply(this, arguments);
    },
    /*
    Helper for create child view
    @return child view
    */

    createChild: function(options) {
      var item;

      item = new this.ChildType(options);
      return this.addChild(item);
    },
    /*
    Helper for add child view
    @return adding view
    */

    addChild: function(view) {
      var _ref;

      log.info("addChild " + this.cid);
      this.childrenViews[view.cid] = view;
      if ((_ref = view.parentView) != null) {
        _ref.removeChild(view);
      }
      view.parentView = this;
      this.updateViewModes();
      return view;
    },
    /*
    Helper remove children view
    @return removing view
    */

    removeChild: function(view) {
      log.info("removeChild " + this.cid);
      delete this.childrenViews[view.cid];
      if (view != null) {
        delete view.parentView;
      }
      if (_.size(this.childrenViews) === 0) {
        this.remove();
      } else {
        this.updateViewModes();
      }
      return view;
    },
    /*
    Helper for set parent view
    */

    setParent: function(view) {
      log.info("setParent " + this.cid);
      if (this.parentView != null) {
        this.parentView.removeChild(this);
      }
      this.parentView = view;
      if (view != null) {
        view.childrenViews[this.cid] = this;
      }
      view.updateViewModes();
      return view;
    },
    /*
    Clear DOM element from span* and offset* classes
    */

    cleanSpan: function($el) {
      var clazz;

      if ((clazz = $el.attr("class"))) {
        clazz = clazz.replace(/span\d{1,2}/g, "").replace(/offset\d{1,2}/g, "");
        $el.attr("class", clazz.trim());
      }
      return $el;
    }
  });
  return Backbone;
});
