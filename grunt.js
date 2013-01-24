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
        src: ["templates/index.jade"],
        dest: "www",
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
        src: ["static/coffee/*.coffee"],
        dest: "www/static/js",
        options: {
            bare: true
        }
      }
    },
    copy: {      
      dist : {
        flatten: true,
        files: {          
          "www/static/js/":
          [
            "static/js/*.js",
            "components/backbone/backbone.js",
            "components/underscore/underscore.js",
            "components/jquery/jquery.js"
          ],
          "www/static/js/bootstrap/":"components/bootstrap/docs/assets/js/*.js",          
          "www/static/img/": "components/bootstrap/img/*.png",
          "www/static/css/bootstrap/":
          [
            "components/bootstrap/docs/assets/css/bootstrap-responsive.css",
            "components/bootstrap/docs/assets/css/bootstrap.css"
          ],
          "www/static/font-awesome/font/":"components/font-awesome/font/**",
          "www/static/font-awesome/css/":
          [
            "components/font-awesome/css/font-awesome.min.css",
            "components/font-awesome/css/font-awesome-ie7.min.css"
          ],
          "www/static/js/jquery-ui/":
          [
            "components/jquery-ui/ui/jquery.ui.core.js",
            "components/jquery-ui/ui/jquery.ui.widget.js",
            "components/jquery-ui/ui/jquery.ui.mouse.js",
            "components/jquery-ui/ui/jquery.ui.resizable.js",
            "components/jquery-ui/ui/jquery.ui.draggable.js",
            "components/jquery-ui/ui/jquery.ui.droppable.js",
            "components/jquery-ui/ui/jquery.ui.sortable.js"
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
        base: "./www"
      }
    },
    watch:{
      jade_shell:{
        files:["templates/*.jade","templates/*/*.jade","templates/*/*/*.jade"],
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
  grunt.registerMultiTask("connect","Run a simple static connect server till you shut it down",function(){    
    var path = require('path');
    this.async();
    var express = require('express');
    var port = this.data.port || 1337;
    var base = this.data.base || __dirname;
    var app = express();
    app.use(express.bodyParser());
    app.use(express.static(base));
    var data = [];
    app.get("/forms.json",function(req,res){            
      res.send(data);
    });
    app.post("/forms.json",function(req, res){      
      data = req.body;
    });
    app.listen(port);

  });
  grunt.registerTask("default","clean copy jade less coffee watch");
  grunt.registerTask("open","clean copy jade less coffee connect");
  
  grunt.loadNpmTasks("grunt-contrib-copy");
  grunt.loadNpmTasks("grunt-clean");
  //grunt.loadNpmTasks("grunt-connect");
  grunt.loadNpmTasks("grunt-coffee");
  grunt.loadNpmTasks("grunt-contrib-less");
  grunt.loadNpmTasks("grunt-jade");
  grunt.loadNpmTasks("grunt-shell");
};
