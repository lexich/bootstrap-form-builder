module.exports = function (grunt) {

  grunt.initConfig({
    less: {
      development: {        
        files: {
          "www/static/css/style.css": "static/less/style.less"
        }
      }
    },
    jade: {
      html: {
        src: ['templates/index.jade'],
        dest: 'www',
        options: {        
          client: false
        }
      }
    },
    shell: {
      jade: {
        command : "jade -P -O www templates/index.jade",
        stdout: true
      },
      less:{
        command : "lessc static/less/style.less www/static/css/style.css",
        stdout: true
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
      jade_shell:{
        files:["templates/*.jade","templates/*/*.jade"],
        tasks:["jade"]
      },
      coffee_shell:{
        files:"static/coffee/*.coffee",
        tasks:["coffee"]
      },
      less_shell:{
        files:"static/less/*.less",
        tasks:["less"]
      }
    }
  });
  grunt.registerTask('default',"clean copy jade less coffee watch");
  grunt.registerTask('open',"clean copy jade less coffee connect");
  
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-clean');
  grunt.loadNpmTasks('grunt-connect');
  grunt.loadNpmTasks('grunt-coffee');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-jade');
  grunt.loadNpmTasks('grunt-shell');
};
