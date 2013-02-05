module.exports = function (grunt) {
  var path = require("path");
  var fs = require("fs");

  grunt.initConfig({
    less: {
      development: {
        files: {
          "www/static/css/style.css": "static/less/style.less"
        }
      }
    },    
    shell: {    
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
        src: [
          "static/coffee/*.coffee",
          "static/coffee/**/*.coffee",
          "static/coffee/**/**/*.coffee"
        ],
        dest: "www/static/js/",
        options: {
            bare: true,
            preserve_dirs: true,
            base_path: 'static/coffee'
        }
      }
    },
    copy: {
      dist : {
        flatten: false,
        files: {
          "www/static/js/":"components/requirejs-text/text.js",
          "www/static/js/jquery/":"components/jquery/jquery.js",
          "www/static/js/backbone/":"components/backbone/backbone.js",
          "www/static/js/underscore/":"components/underscore/underscore.js",
          "www/static/js/bootstrap/":"components/bootstrap/docs/assets/js/*.js",
          "www/static/js/requirejs/":"components/requirejs/require.js",
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
          ],
          "www/static/js/jasmine/":[
            "components/jasmine/lib/jasmine-core/jasmine.js",
            "components/jasmine/lib/jasmine-core/jasmine-html.js"
          ],
          "www/static/css/jasmine/":[
            "components/jasmine/lib/jasmine-core/jasmine.css"
          ],
          "www/static/plugins/select2/":[
            "components/select2/select2.css",
            "components/select2/select2.js",
            "components/select2/select2.png",
            "components/select2/spinner.gif"
          ],
          "www/static/js/sinon/":"components/sinon.js/sinon.js",
          "www/static/templates/":"static/templates/*.html"
        }
      }
    },
    clean:{
      folder:"www"
    },
    connect: {
      server: {
        port: 9090,
        base: "./www"
      }
    },
    reload: {
        port: 6001,
        proxy: {
            host: 'localhost',
            port: 9090
        }
    },
    watch:{
      swig:{
        files:["templates/*.html","templates/**/*.html","templates/**/**/*.html"],
        tasks:["swig", "reload"]
      },
      coffee_shell:{
        files:["static/coffee/*.coffee","static/coffee/**/*.coffee"],
        tasks:["coffee","reload"]
      },
      less_shell:{
        files:"static/less/*.less",
        tasks:["less","reload"]
      }
    },
    swig:{
      development:{
        root:"templates",
        out:"www",
        files:[
          "index.html","test.html"
        ]                 
      }
    }
  });
  grunt.registerTask("bower", function(){
    var done = this.async();
    var input   = process.argv;
    var cwd = 'install';
    require('bower').commands[cwd].line(input)
      .on('data', function (data) {
        if (data) {
          console.log(data);
        }
      })
      .on('end', function (data) {
        if (data) {
          console.log(data);
        }
        done();
      })
      .on('error', function (err) {
        console.error(err.message);
        done();
      });
      
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
    var data = [
      {label:"Name", placeholder:"Input your name", name:"name", type:"input", position:0, row:0},
      {label:"Comment", placeholder:"Your comment", name:"comment", type:"textarea", position:1, row:0}
    ];
    app.get("/forms.json",function(req,res){
      res.send(data);
    });
    app.post("/forms.json",function(req, res){
      data = req.body;
    });
    app.listen(port);
  });

  grunt.registerMultiTask("swig","Run swig",function(){
    var swig = require("swig");
    var html = require("html");
    
    swig.init({
      root:this.data.root,
      autoescape: true,
      allowErrors: true,
      encoding:"utf8"
    });
    try{
      var out = this.data.out;
      this.data.files.forEach(function(file){
        var tmpl = swig.compileFile(file);
        var data = tmpl.render({});
        var prettyData = html.prettyPrint(data, {indent_size: 2});
        var outFile = path.join(out, file );
        fs.writeFileSync(outFile, prettyData);
        console.log("write: " + outFile);
      });      
    } catch (err){
      console.error(err);
    }
    
  });

  grunt.registerTask("default","clean bower copy less coffee swig connect");
  grunt.registerTask("dev","clean copy less coffee swig watch");
  
  
  grunt.loadNpmTasks("grunt-contrib-copy");
  grunt.loadNpmTasks("grunt-clean");
  //grunt.loadNpmTasks("grunt-connect");
  grunt.loadNpmTasks("grunt-coffee");
  grunt.loadNpmTasks("grunt-contrib-less");  
  grunt.loadNpmTasks("grunt-shell");
  grunt.loadNpmTasks('grunt-reload');
};
