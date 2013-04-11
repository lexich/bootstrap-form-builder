html = require("html")
fs = require("fs")
path = require("path")
swig = require("swig")

module.exports = (grunt)->
  grunt.registerMultiTask "swig", "Run swig", ->
    normalize = (filepath)=>
      if filepath then filepath.replace(@data.root,"") else false

    @files.forEach (filePair) =>
      try
        swig.init
          root: filePair.orig.cwd
          autoescape: true
          allowErrors: true
          encoding: "utf8"
        src = filePair.orig.src[0]
        tmpl = swig.compileFile(src)
        data = tmpl.render
          compile:
            livereload: @data.livereload or false
            compress_css: normalize(@data.compress_css)
            compress_cssie7: normalize(@data.compress_cssie7)
            compress_js: normalize(@data.compress_js)
          static_folder: @data.static_folder

        prettyData = html.prettyPrint(data, indent_size: 2)
        grunt.file.write(filePair.dest, prettyData)
        grunt.log.writeln "Compile " + filePair.src[0].green + " -> ".yellow + filePair.dest.green
      catch err
        grunt.log.error err