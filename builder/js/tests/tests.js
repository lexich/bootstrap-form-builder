require(["tests/model/FormItem-model.test", "tests/collection/FormItem-collection.test", "tests/view/Form-view.test", "tests/view/Modal-view.test", "tests/view/FormItem-view.test", "tests/common/BackboneCustomView.test"], function() {
  var currentWindowOnload, execJasmine, jasmineEnv, trivialReporter;

  jasmineEnv = jasmine.getEnv();
  jasmineEnv.updateInterval = 1000;
  trivialReporter = new jasmine.TrivialReporter();
  jasmineEnv.addReporter(trivialReporter);
  execJasmine = function() {
    return jasmineEnv.execute();
  };
  jasmineEnv.specFilter = function(spec) {
    return trivialReporter.specFilter(spec);
  };
  currentWindowOnload = window.onload;
  if (currentWindowOnload) {
    currentWindowOnload();
  }
  return execJasmine();
});
