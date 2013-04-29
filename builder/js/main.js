require(["jquery", "backbone", "view/Modal-view", "common/Service", "collection/FormItem-collection", "view/Form-view", "view/ToolItem-view", "view/Settings-view", "view/NotVisual-view", "common/Log", "html2canvas/html2canvas", "bootstrap"], function($, Backbone, ModalView, Service, FormItemCollection, FormView, ToolItemView, SettingsView, NotVisualView, Log, html2canvas) {
  var ALL, CHECK, DEBUG, ERROR, INFO, WARN, initCsrf, log;

  DEBUG = Log.LEVEL.DEBUG;
  INFO = Log.LEVEL.INFO;
  WARN = Log.LEVEL.WARN;
  ERROR = Log.LEVEL.ERROR;
  CHECK = WARN | ERROR;
  ALL = DEBUG | INFO | WARN | ERROR;
  Log.initConfig({
    "view/FormView": {
      level: CHECK
    },
    "view/FieldsetView": {
      level: CHECK
    },
    "view/FieldsetView_CustomView": {
      level: CHECK
    },
    "view/FieldsetView_UIView": {
      level: CHECK
    },
    "view/FormItemView": {
      level: CHECK
    },
    "view/ModalView": {
      level: CHECK
    },
    "view/RowView": {
      level: CHECK
    },
    "view/RowViewSortableHandlers": {
      level: CHECK
    },
    "view/RowViewCustomView": {
      level: CHECK
    },
    "view/SettingsView": {
      level: CHECK
    },
    "view/ToolItemView": {
      level: CHECK
    },
    "view/NotVisual": {
      level: CHECK
    },
    "common/CustomView": {
      level: CHECK
    },
    "common/Service": {
      level: CHECK
    },
    "collection/FormItemCollection": {
      level: CHECK
    },
    "collection/FieldsetCollection": {
      level: CHECK
    },
    "main": {
      level: CHECK
    }
  });
  log = Log.getLogger("main");
  initCsrf = function() {
    var $el, csrfToken, safeMethod, sameOrigin;

    sameOrigin = function(url) {
      var host, origin, protocol, sr_origin;

      host = document.location.host;
      protocol = document.location.protocol;
      sr_origin = "//" + host;
      origin = protocol + sr_origin;
      return (url === origin || url.slice(0, origin.length + 1) === origin + "/") || (url === sr_origin || url.slice(0, sr_origin.length + 1) === sr_origin + "/") || !(/^(\/\/|http:|https:).*/.test(url));
    };
    safeMethod = function(method) {
      return /^(GET|HEAD|OPTIONS|TRACE)$/.test(method);
    };
    $el = $("meta[name=\"CSRFToken\"]");
    if ($el.length !== 1) {
      log.warn("initCsrf - meta csrf not found");
      return;
    }
    csrfToken = $el.attr("content");
    return $(document).ajaxSend(function(event, xhr, settings) {
      if (!safeMethod(settings.type) && sameOrigin(settings.url)) {
        return xhr.setRequestHeader("CSRFToken", csrfToken);
      }
    });
  };
  return $(document).ready(function() {
    var collection, formView, notVisual, param, service, settings, url, _ref, _ref1, _ref2, _ref3,
      _this = this;

    initCsrf();
    url = (_ref = (_ref1 = window.rootformconfig) != null ? _ref1.url : void 0) != null ? _ref : "/forms.json";
    param = (_ref2 = (_ref3 = window.rootformconfig) != null ? _ref3.param : void 0) != null ? _ref2 : "id";
    if (url.indexOf("?") === -1) {
      url += "?";
    }
    _.each(window.location.search.replace("?", "").split("&"), function(query) {
      if (query.indexOf("" + param + "=") === 0) {
        return url += "" + query + "&";
      }
    });
    collection = new FormItemCollection({
      url: url
    });
    service = new Service({
      dataToolBinder: "ui-jsrender",
      collection: collection,
      areaTemplateItem: "",
      dataPostfixModalType: "modal-type"
    });
    formView = new FormView({
      className: "ui_workarea",
      el: $("[data-html-form]:first"),
      dataDropAccept: "drop-accept",
      collection: collection,
      service: service
    });
    notVisual = new NotVisualView({
      className: "ui_notvisual",
      el: $("[data-html-notvisual]:first"),
      collection: collection,
      service: service
    });
    settings = new SettingsView({
      el: $("[data-html-settings]:first"),
      dataPostfixModalType: "modal-type",
      service: service,
      collection: collection
    });
    _.each(service.toolData, function(data, type) {
      var toolItem;

      toolItem = new ToolItemView({
        type: type,
        service: service,
        data: data
      });
      return toolItem.render();
    });
    $("[data-js-global-form-save]").click(function() {
      $("body").addClass("ui_printform");
      return html2canvas($("[data-html-form]:first"), {
        onrendered: function(canvas) {
          var data;

          data = canvas.toDataURL();
          data = data.replace("data:image/png;base64,", "");
          collection.updateAll({
            img: data
          });
          return $("body").removeClass("ui_printform");
        }
      });
    });
    return collection.fetch();
  });
});
