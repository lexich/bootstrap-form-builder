define([], function() {
  "use strict";
  var ctx;

  ctx = {};
  (function(ctx) {
    var DEBUG, ERROR, INFO, Log, MessageProcesor, WARN, instance;

    MessageProcesor = function(name, level) {
      this.name = name;
      return this.setLevel(level);
    };
    Log = function() {
      var instance;

      if (instance === void 0) {
        instance = this;
        this.options = {};
      }
      return instance;
    };
    instance = void 0;
    ERROR = 1 << 3;
    WARN = 1 << 2;
    DEBUG = 1 << 1;
    INFO = 1 << 0;
    Log.prototype = {
      constructor: Log,
      LEVEL: {
        INFO: INFO,
        DEBUG: DEBUG,
        WARN: WARN,
        ERROR: ERROR
      },
      /*
      @param options
      name -
      level - {value} default LOG.LEVEL.ERROR
      */

      initConfig: function(options) {
        var current, key, param, _results;

        _results = [];
        for (key in options) {
          this.options[key] = this.options[key] || {};
          current = this.options[key];
          param = options[key];
          if (param.level) {
            current.level = param.level;
            if (current.logger) {
              _results.push(current.logger.setLevel(param.level));
            } else {
              _results.push(void 0);
            }
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      },
      getLogger: function(name) {
        var def, level, logger, option;

        this.options[name] = this.options[name] || {};
        option = this.options[name];
        def = this.LEVEL.ERROR | this.LEVEL.WARN;
        level = (option ? option.level || def : def);
        logger = new MessageProcesor(name, level);
        logger.prototype = {};
        logger.constructor = function() {};
        option.logger = logger;
        return logger;
      }
    };
    MessageProcesor.prototype = {
      constructor: MessageProcesor,
      msg: function(msg, level) {
        var is_;

        is_ = this.level & level;
        if (is_ !== 0) {
          return this.execute(msg, level, this.name);
        }
      },
      execute: function(message, level, name) {
        var msg;

        msg = "(" + name + ") - " + message;
        if (level === Log.prototype.LEVEL.INFO) {
          return console.info("INFO: " + msg);
        } else if (level === Log.prototype.LEVEL.WARN) {
          return console.warn("WARN: " + msg);
        } else if (level === Log.prototype.LEVEL.ERROR) {
          return console.error("ERROR: " + msg);
        } else {
          if (level === Log.prototype.LEVEL.DEBUG) {
            return console.debug("DEBUG: " + msg);
          }
        }
      },
      setLevel: function(level) {
        return this.level = level;
      },
      info: function(msg) {
        return this.msg(msg, Log.prototype.LEVEL.INFO);
      },
      debug: function(msg) {
        return this.msg(msg, Log.prototype.LEVEL.DEBUG);
      },
      warn: function(msg) {
        return this.msg(msg, Log.prototype.LEVEL.WARN);
      },
      error: function(msg) {
        return this.msg(msg, Log.prototype.LEVEL.ERROR);
      }
    };
    return ctx.Log = new Log();
  })(ctx);
  return ctx.Log;
});
