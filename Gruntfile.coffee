module.exports = (grunt) ->
  path = require("path")
  fs = require("fs")
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    components: "components"

    resource:
      path: "www/static"
      js: "<%= resource.path %>/js"
      css: "<%= resource.path %>/css/"
      img: "<%= resource.path %>/img"
      font: "<%= resource.path %>/font"
      templates: "<%= resource.path %>/templates"
      build: "<%= resource.path %>/build"

    less:
      common:
        files:
          "www/static/css/style.css": "static/less/style.less"

    coffee:
      common:
        expand: true
        src: ["*.coffee", "**/*.coffee", "**/**/*.coffee"]
        cwd: "static/coffee/"
        dest: "<%= resource.js %>/"
        rename: (dest, filename, orig)->
          dest + filename.replace /\.coffee$/g, ".js"
        options:
          bare: true

    copy:
      html5sortable:
        files:[
          flattern: true
          expand: true
          src: "jquery.sortable.js"
          cwd: "<%= components %>/html5sortable/"
          dest: "<%= resource.js %>/html5sortable/"
        ]
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
          src: "*.css"
          cwd: "<%= components %>/bootstrap/docs/assets/css/"
          dest: "<%= resource.css %>/"
        ,
          flattern: true
          expand: true
          src: "*.png"
          cwd: "<%= components %>/bootstrap/img/"
          dest: "<%= resource.img %>/"
        ]
      font_awesome:
        files: [
          flattern: true
          expand: true
          src: ["font-awesome.min.css", "font-awesome-ie7.min.css"]
          cwd: "<%= components %>/font-awesome/css/"
          dest: "<%= resource.css %>/"
        ,
          flattern: true
          expand: true
          src: "**"
          cwd: "<%= components %>/font-awesome/font/"
          dest: "<%= resource.font %>/"
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
      fuelux:
        files:[
          flattern: true
          expand: true
          src: "*.js"
          cwd: "<%= components %>/fuelux/dist"
          dest: "<%= resource.js %>/fuelux/"
        ,
          flattern: true
          expand: true
          src: "*.min.css"
          cwd: "<%= components %>/fuelux/dist/css"
          dest: "<%= resource.css %>/"
        ,
          flattern: true
          expand: true
          src: "*.png"
          cwd: "<%= components %>/fuelux/dist/img"
          dest: "<%= resource.img %>/"
        ]
      jasmine:
        files:[
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
          dest: "<%= resource.css %>/"
        ]
      select2:
        files:[
          flattern: true
          expand: true
          src: "select2.js"
          cwd: "<%= components %>/select2/"
          dest: "<%= resource.js %>/select2/"
        ,
          flattern: true
          expand: true
          src: "select2.css"
          cwd: "<%= components %>/select2/"
          dest: "<%= resource.css %>/"
        ,
          flattern: true
          expand: true
          src: ["*.png","*.gif"]
          cwd: "<%= components %>/select2/"
          dest: "<%= resource.img %>/"
        ]
      datepicker:
        files:[
          flattern: true
          expand: true
          src:"bootstrap-datepicker.js"
          cwd: "<%= components %>/bootstrap-datepicker/js"
          dest: "<%= resource.js %>/datepicker/"
        ,
          flattern: true
          expand: true
          src: "datepicker.css"
          cwd: "<%= components %>/bootstrap-datepicker/css"
          dest: "<%= resource.css %>/"
        ]
      templates:
        files:[
          flattern: true
          expand: true
          src: "*.html"
          cwd: "static/templates/"
          dest: "<%= resource.templates %>/"
        ]
      backbone:
        files:[
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
          src: "sinon.js"
          cwd: "<%= components %>/sinon.js/"
          dest: "<%= resource.js %>/sinon/"
        ]

    clean:
      folder: "www"

    connect2:
      dev:
        port: 9090
        base: "./www"
      release:
        port: 9090
        base: "./www"
        keepalive: true

    livereload:
      port: 6001
      proxy:
        host: "localhost"
        port: 9090

    concat:
      css:
        src:[
          "<%= resource.css %>/bootstrap.css"
          "<%= resource.css %>/bootstrap-responsive.css"
          "<%= resource.css %>/fuelux.min.css"
          "<%= resource.css %>/fuelux-responsive.min.css"
          "<%= resource.css %>/font-awesome.min.css"
          "<%= resource.css %>/datepicker.css"
          "<%= resource.css %>/select2.css"
          "<%= resource.css %>/style.css"
        ]
        dest: "<%= resource.build %>/style-<%= pkg.name %>-<%= pkg.version %>.css"
      css_ie7:
        src:[
          "<%= resource.css %>/font-awesome-ie7.min.css"
        ]
        dest: "<%= resource.build %>/style-<%= pkg.name %>-<%= pkg.version %>.ie7.css"

    cssmin:
      common:
        filename: "<%= resource.build %>/style-<%= pkg.name %>-<%= pkg.version %>.min.css"
        files: "<%= cssmin.common.filename %>":"<%= concat.css.dest %>"
      common_ie7:
        filename: "<%= resource.build %>/style-<%= pkg.name %>-<%= pkg.version %>.ie7.min.css"
        files:"<%= cssmin.common_ie7.filename %>":"<%= concat.css_ie7.dest %>"

    requirejs:
      common:
        options:
          name: "main"
          baseUrl: "<%= resource.js %>/"
          mainConfigFile: "<%= resource.js %>/config.js"
          out: "<%= resource.build %>/main-<%= pkg.name %>-<%= pkg.version %>.js"

    watch:
      swig:
        files: ["templates/*.html", "templates/**/*.html", "templates/**/**/*.html"]
        tasks: ["swig:dev"]

      coffee_shell:
        files: ["static/coffee/*.coffee", "static/coffee/**/*.coffee"]
        tasks: ["coffee"]

      less_shell:
        files: "static/less/*.less"
        tasks: ["less"]

      templates:
        files: "static/templates/*.html"
        tasks: ["copy:templates"]

    swig:
      dev:
        root: "www"
        livereload: false
        files: [
          src: ["index.html", "test.html", "dragndrop.html"]
          cwd: "templates"
          dest: "www/"
        ]
      release:
        root: "www"
        compress_css:"<%= cssmin.common.filename %>"
        compress_cssie7: "<%= cssmin.common_ie7.filename %>"
        compress_js: "<%= requirejs.common.options.out %>"
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
    express = require("express")
    port = @data.port or 1337
    base = @data.base or __dirname
    keepalive = @data.keepalive ? false
    if keepalive then @async()
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
    dataArea = {}

    app.get "/area.json", (req, res)->
      row = parseInt(req.query.row or 0)
      unless dataArea[row]?
        dataArea[row] =
          title: "Test Area"
          row: row
          direction: "horizontal"
      res.send dataArea[row]

    app.post "/area.json", (req, res)->
      d = req.body
      row = parseInt(d.row or 0)
      dataArea[d.row] = d

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
    normalize = (filepath)=>
      if filepath then filepath.replace(@data.root,"") else false
    try
      @data.files.forEach (files) =>
        swig = require("swig")
        swig.init
          root: files.cwd
          autoescape: true
          allowErrors: true
          encoding: "utf8"

        files.src.forEach (file)=>
          tmpl = swig.compileFile(file)
          data = tmpl.render
            compile:
              livereload: @data.livereload or false
              compress_css: normalize(@data.compress_css)
              compress_cssie7: normalize(@data.compress_cssie7)
              compress_js: normalize(@data.compress_js)

          prettyData = html.prettyPrint(data, indent_size: 2)
          outFile = path.join(files.dest, file)
          fs.writeFileSync outFile, prettyData
          console.log "write: " + outFile
    catch err
      console.error err


  grunt.registerTask "css-gen", ["less:common", "concat"]
  grunt.registerTask "css-min", ["css-gen", "cssmin"]
  grunt.registerTask "js-min", ["coffee:common", "requirejs:common"]
  grunt.registerTask "swig-release", ["copy", "css-min","js-min","swig:release"]
  grunt.registerTask "swig-dev", ["copy", "css-gen","coffee:common","swig:dev"]

  grunt.registerTask "default", ["clean", "swig-release","connect2:release"]
  grunt.registerTask "dev", ["clean", "swig-dev","connect2:dev", "watch"]

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-contrib-watch"