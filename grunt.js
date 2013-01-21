module.exports = function (grunt) {

  grunt.initConfig({
    shell: {
      jade: {
        command : "jade -P -O www templates/index.jade"
      },
      less:{
        command : "lessc static/less/style.less www/static/css/style.css"
      }
    },
    lint:{
      files: [
        "grunt.js"
      ]
    },
    coffee: {
      app: {
        src: ['static/coffee/*.coffee'],
        dest: 'www/static/js',
        options: {
            bare: true
        }
      }
    },
    copy: {      
      dist : {
        files: {          
          'www/static/js/':[
            'static/js/*.js',
            'components/backbone/backbone.js',
            'components/underscore/underscore.js',
            'components/jquery/jquery.js'
          ],
          'www/static/js/bootstrap/':"components/bootstrap/docs/assets/js/*.js",
          'www/static/img/':[
            "components/bootstrap/img/*.png"
          ],
          'www/static/css/':[
            "static/css/style.css",
            "components/bootstrap/docs/assets/css/bootstrap-responsive.css",
            "components/bootstrap/docs/assets/css/bootstrap.css"
          ],          
          "www/static/js/jquery-ui/":[
            'components/jquery-ui/ui/jquery.ui.core.js',
            'components/jquery-ui/ui/jquery.ui.widget.js',
            'components/jquery-ui/ui/jquery.ui.mouse.js',
            'components/jquery-ui/ui/jquery.ui.resizable.js',
            'components/jquery-ui/ui/jquery.ui.draggable.js',
            'components/jquery-ui/ui/jquery.ui.droppable.js',
            'components/jquery-ui/ui/jquery.ui.sortable.js'
          ]
        }
      }
    },
    clean:{
      folder:"www"
    },
    connect: {
      server: {
        port: 8080,
        base: './www'
      }
    },
    watch:{
      jade:{
        files:"templates/*.jade",
        tasks:["shell:jade"]
      },
      coffee:{
        files:"static/coffee/*.coffee",
        tasks:["coffee"]
      },
      less:{
        files:"static/less/*.less",
        tasks:["shell:less"]
      }
    }
  });
  grunt.registerTask('default',"clean copy shell coffee watch");
  grunt.registerTask('open',"clean copy shell coffee connect");
  
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-clean');
  grunt.loadNpmTasks('grunt-connect');
  grunt.loadNpmTasks('grunt-coffee');
  grunt.loadNpmTasks('grunt-shell');
};