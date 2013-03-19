require [
  "tests/model/DropArea-model.test"
  "tests/collection/DropArea-collection.test"
  "tests/view/DropArea-view.test"
  "tests/view/Form-view.test"
  "tests/view/Modal-view.test"
  "tests/view/FormItem-view.test"
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