define [
         "backbone",
         "underscore"
],(Backbone,_)->

  DropAreaModel = Backbone.Model.extend
    DEFAULT_URL: "/area.json"
    HORIZONTAL:"horizontal"
    VERTICAL: "vertical"

    initialize:(options)->
      @url = if options.url then options.url else @DEFAULT_URL

    defaults:
      direction: "horizontal"
      title: "Title"
      row: 0

    validate:(attrs, options)->
      if attrs.row < 0
        "row must be >= 0"
      else if attrs.direction not in [@HORIZONTAL,@VERTICAL]
        "direction must be [horizontal,vertical]"
      else if attrs.title is null or attrs.title is ""
        "title mustn't be not null"

  DropAreaModel