module.exports = (grunt) ->
  path = require("path")
  fs = require("fs")
  grunt.initConfig
    components: "components"

    resource:
      path: "www/static"
      js: "<%= resource.path %>/js"
      css: "<%= resource.path %>/css"
      img: "<%= resource.path %>/img"
      templates: "<%= resource.path %>/templates"

    less:
      development:
        files:
          "www/static/css/style.css": "static/less/style.less"

    shell:
      less:
        command: "lessc static/less/style.less www/static/css/style.css"
        stdout: true

    lint:
      files: ["grunt.js"]

    coffee:
      app:
        expand: true
        src: ["*.coffee", "**/*.coffee", "**/**/*.coffee"]
        cwd: "static/coffee/"
        dest: "<%= resource.js %>/"
        rename: (dest, filename, orig)->
          dest + filename.replace /\.coffee$/g, ".js"
        options:
          bare: true

    copy:
      bootstrap:
        files:[
          flattern: true
          expand: true
          src: "*.js"
          cwd: "<%= components %>/bootstrap/docs/assets/js/"
          dest: "<%= resource.js %>/bootstrap/"
        ,
          flattern: true
          expand: true
          src: "*.png"
          cwd: "<%= components %>/bootstrap/img/"
          dest: "<%= resource.img %>/"
        ,
          flattern: true
          expand: true
          src: "*.css"
          cwd: "<%= components %>/bootstrap/docs/assets/css/"
          dest: "<%= resource.css %>/bootstrap/"
        ]
      font_awesome:
        files: [
          flattern: true
          expand: true
          src: "**"
          cwd: "<%= components %>/font-awesome/font/"
          dest: "<%= resource.path %>/font-awesome/font/"
        ,
          flattern: true
          expand: true
          src: ["font-awesome.min.css", "font-awesome-ie7.min.css"]
          cwd: "<%= components %>/font-awesome/css/"
          dest: "<%= resource.path %>/font-awesome/css/"
        ]
      requirejs:
        files:[
          flattern: true
          expand: true
          src: "text.js"
          cwd: "<%= components %>/requirejs-text/"
          dest: "<%= resource.js %>/"
        ,
          flattern: true
          expand: true
          src: "require.js"
          cwd: "<%= components %>/requirejs/"
          dest: "<%= resource.js %>/requirejs/"
        ]
      common:
        files:[
          flattern: true
          expand: true
          src: "jquery.js"
          cwd: "<%= components %>/jquery/"
          dest: "<%= resource.js %>/jquery/"
        ,
          flattern: true
          expand: true
          src: "backbone.js"
          cwd: "<%= components %>/backbone/"
          dest: "<%= resource.js %>/backbone/"
        ,
          flattern: true
          expand: true
          src: "underscore.js"
          cwd: "<%= components %>/underscore"
          dest: "<%= resource.js %>/underscore"
        ,
          flattern: true
          expand: true
          src: ["*.png","**/*.png"]
          cwd: "static/img/"
          dest: "<%= resource.img %>/"
        ,
          flattern: true
          expand: true
          src: [
            "jquery.ui.core.js"
            "jquery.ui.widget.js"
            "jquery.ui.mouse.js"
            "jquery.ui.resizable.js"
            "jquery.ui.draggable.js"
            "jquery.ui.droppable.js"
            "jquery.ui.sortable.js"
          ]
          cwd: "<%= components %>/jquery-ui/ui/"
          dest: "<%= resource.js %>/jquery-ui/"
        ,
          flattern: true
          expand: true
          src: [
            "jasmine.js"
            "jasmine-html.js"
          ]
          cwd: "<%= components %>/jasmine/lib/jasmine-core/"
          dest: "<%= resource.js %>/jasmine/"
        ,
          flattern: true
          expand: true
          src: "jasmine.css"
          cwd: "<%= components %>/jasmine/lib/jasmine-core/"
          dest: "<%= resource.css %>/jasmine/"
        ,
          flattern: true
          expand: true
          src: [
            "select2.css"
            "select2.js"
            "select2.png"
            "spinner.gif"
          ]
          cwd: "<%= components %>/select2/"
          dest: "<%= resource.path %>/plugins/select2/"
        ,
          flattern: true
          expand: true
          src: [
            "css/datepicker.css"
            "js/bootstrap-datepicker.js"
          ]
          cwd: "<%= components %>/bootstrap-datepicker/"
          dest: "<%= resource.path %>/plugins/datepicker/"
        ,
          flattern: true
          expand: true
          src: "sinon.js"
          cwd: "<%= components %>/sinon.js/"
          dest: "<%= resource.js %>/sinon/"
        ,
          flattern: true
          expand: true
          src: "*.html"
          cwd: "static/templates/"
          dest: "<%= resource.templates %>/"
        ]

    clean:
      folder: "www"

    connect2:
      server:
        port: 9090
        base: "./www"

    reload:
      port: 6001
      proxy:
        host: "localhost"
        port: 9090

    watch:
      swig:
        files: ["templates/*.html", "templates/**/*.html", "templates/**/**/*.html"]
        tasks: ["swig", "reload"]

      coffee_shell:
        files: ["static/coffee/*.coffee", "static/coffee/**/*.coffee"]
        tasks: ["coffee", "reload"]

      less_shell:
        files: "static/less/*.less"
        tasks: ["less", "reload"]

    swig:
      development:
        files: [
          src: ["index.html", "test.html"]
          cwd: "templates"
          dest: "www/"
        ]

  grunt.registerTask "bower", ->
    done = @async()
    input = process.argv
    cwd = "install"
    require("bower").commands[cwd].line(input).on("data", (data) ->
      console.log data  if data
    ).on("end", (data) ->
      console.log data  if data
      done()
    ).on "error", (err) ->
      console.error err.message
      done()


  grunt.registerMultiTask "connect2", "Run a simple static connect server till you shut it down", ->
    path = require("path")
    @async()
    express = require("express")
    port = @data.port or 1337
    base = @data.base or __dirname
    app = express()
    app.use express.bodyParser()
    app.use express.static(base)
    data = [
      label: "Name"
      placeholder: "Input your name"
      name: "name"
      type: "input"
      position: 0
      row: 0
    ,
      label: "Comment"
      placeholder: "Your comment"
      name: "comment"
      type: "textarea"
      position: 1
      row: 0
    ]
    app.get "/forms.json", (req, res) ->
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

  grunt.registerMultiTask "swig", "Run swig", ->
    html = require("html")


    try
      @data.files.forEach (files) ->
        swig = require("swig")
        swig.init
          root: files.cwd
          autoescape: true
          allowErrors: true
          encoding: "utf8"
        files.src.forEach (file)->
          tmpl = swig.compileFile(file)
          data = tmpl.render({})
          prettyData = html.prettyPrint(data,
            indent_size: 2
          )
          outFile = path.join(files.dest, file)
          fs.writeFileSync outFile, prettyData
          console.log "write: " + outFile

    catch err
      console.error err

  grunt.registerTask "default", ["clean", "bower", "copy", "less", "coffee", "swig", "connect2"]
  grunt.registerTask "dev", ["clean", "copy", "less", "coffee", "swig", "watch"]
  

  grunt.loadNpmTasks('grunt-contrib');
  grunt.loadNpmTasks "grunt-reload"
