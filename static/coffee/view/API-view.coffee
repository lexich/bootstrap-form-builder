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
    init_select2: ->
      $el = $("input,select", @$el)
      more = parseInt $el.data("js-more") ? 20
      options =
        placeholder: $el.data("js-placeholder")
        ajax:
          url: $el.data("js-url")
          data: (term, page)->
            q: $el.data("js-q")
            page_limit: 10
            page: page
          results: (data, page)->
            { results: data.results, more: data.more }

      $el.select2 options

    init_datepicker: ->
      $el = $("input", @$el)
      $el.datepicker()

    init_checkbox: ->
      $el = $("input", @$el)
      $el.checkbox()

    render: ->
      Backbone.CustomView::render.apply this, arguments
      type = @model.get("type")
      method = @["init_#{type}"]
      if _.isFunction(method)
        method.apply this, arguments

  APIView