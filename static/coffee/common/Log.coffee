define [], ->
  "use strict"
  ctx = {}
  ((ctx) ->
    MessageProcesor = (name, level) ->
      @name = name
      @setLevel level

    Log = ->
      if instance is undefined
        instance = this
        @options = {}
      instance

    instance = undefined
    ERROR = 1 << 3
    WARN = 1 << 2
    DEBUG = 1 << 1
    INFO = 1 << 0
    Log:: =
      constructor: Log
      LEVEL:
        INFO: INFO
        DEBUG: DEBUG
        WARN: WARN
        ERROR: ERROR


      ###
      @param options
      name -
      level - {value} default LOG.LEVEL.ERROR
      ###
      initConfig: (options) ->
        for key of options
          @options[key] = @options[key] or {}
          current = @options[key]
          param = options[key]
          if param.level
            current.level = param.level
            current.logger.setLevel param.level  if current.logger

      getLogger: (name) ->
        @options[name] = @options[name] or {}
        option = @options[name]
        def = @LEVEL.ERROR | @LEVEL.WARN
        level = (if option then option.level or def else def)
        logger = new MessageProcesor(name, level)
        logger:: = {}
        logger.constructor = ->

        option.logger = logger
        logger

    MessageProcesor:: =
      constructor: MessageProcesor
      msg: (msg, level) ->
        is_ = @level & level
        @execute msg, level, @name  unless is_ is 0

      execute: (message, level, name) ->
        msg = "(" + name + ") - " + message
        if level is Log::LEVEL.INFO
          console.info "INFO: " + msg
        else if level is Log::LEVEL.WARN
          console.warn "WARN: " + msg
        else if level is Log::LEVEL.ERROR
          console.error "ERROR: " + msg
        else console.debug "DEBUG: " + msg  if level is Log::LEVEL.DEBUG

      setLevel: (level) ->
        @level = level

      info: (msg) ->
        @msg msg, Log::LEVEL.INFO

      debug: (msg) ->
        @msg msg, Log::LEVEL.DEBUG

      warn: (msg) ->
        @msg msg, Log::LEVEL.WARN

      error: (msg) ->
        @msg msg, Log::LEVEL.ERROR

    ctx.Log = new Log()
  ) ctx
  ctx.Log