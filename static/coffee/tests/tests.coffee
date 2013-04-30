require [
  "tests/model/FormItem-model.test"
  "tests/collection/FormItem-collection.test"

  "tests/view/Form-view.test"
  "tests/view/FormItem-view.test"
  "tests/common/BackboneCustomView.test"
],->
  jasmineEnv = jasmine.getEnv();
  jasmineEnv.updateInterval = 1000;

  trivialReporter = new jasmine.TrivialReporter();
  jasmineEnv.addReporter(trivialReporter);
  execJasmine = ->
    jasmineEnv.execute()
  jasmineEnv.specFilter = (spec)->
    trivialReporter.specFilter(spec);
  currentWindowOnload = window.onload;
  
  if currentWindowOnload then currentWindowOnload()    
  execJasmine()  