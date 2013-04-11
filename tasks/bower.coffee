module.exports = (grunt)->
  grunt.registerTask "bower", ->
    done = @async()
    input = process.argv
    cwd = "install"
    require("bower").commands[cwd].line(input).on("data", (data) ->
      grunt.log.writeln data  if data
    ).on("end", (data) ->
      grunt.log.writeln data  if data
      done()
    ).on "error", (err) ->
      grunt.log.error err.message
      done()
