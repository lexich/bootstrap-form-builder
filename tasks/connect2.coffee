path = require("path")
express = require("express")

module.exports = (grunt)->
  grunt.registerMultiTask "connect2", "Run a simple static connect server till you shut it down", ->
    port = @data.port or 1337
    base = path.normalize(@data.base or __dirname)
    keepalive = @data.keepalive ? false
    if keepalive then @async()
    app = express()
    app.use express.bodyParser()

    if @data.static_folder
      app.use @data.static_folder, express.static(base)
    else
      app.use express.static(base)

    for query,handlers of @data.rest
      for url,callback of handlers
        app[query](url, callback)


    app.listen port
