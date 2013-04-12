define [
   "jquery",
   "backbone",
   "underscore",
   "select2",
   "datepicker",
   "fuelux/all"
   "common/BackboneCustomView"
], ($, Backbone, _)->
  APIView = Backbone.CustomView.extend
    viewname:"api"

  APIView