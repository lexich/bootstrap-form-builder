path = require("path")
express = require("express")

module.exports = (grunt)->
  grunt.registerMultiTask "connect2", "Run a simple static connect server till you shut it down", ->
    port = @data.port or 1337
    base = path.normalize(@data.base or __dirname)
    keepalive = @data.keepalive ? false
    indexfile = @data.index ? "index.html"
    if keepalive then @async()
    app = express()

    app.use express.bodyParser()
    console.log base
    app.use "/resources/", express.static(base)

    data = []

    app.get "/",(req, res)=>
      filepath = path.normalize(path.join(__dirname, "..", base, indexfile))
      res.sendfile filepath

    app.get "/forms.json", (req, res) =>
      res.send data

    app.post "/forms.json", (req, res) ->
      data = req.body

    app.get "/select2.json", (req, res) ->
      res.send
        more: false
        results: [
          id: "CA"
          text: "California"
        ,
          id: "AL"
          text: "Alabama"
        ]

    app.listen port
