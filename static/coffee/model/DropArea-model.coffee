define [
  "backbone",
  "underscore"
],(Backbone,_)->
  
  DropAreaModel = Backbone.Model.extend
    defaults:
      label:""
      placeholder:""
      type:"input"
      name:""
      help:""
      position:0
      row:0

    parse:(attrs, options)->
      LOG "DropAreaModel","parse"
      intParams = _.reduce @defaults, (
        (memo,v,k)->
          if isPositiveInt(v) then memo.push k
          memo
      ),[]
      result = _.reduce attrs, ((memo, v,k)->
        if k in intParams
          memo[k] = toInt(v)
        else
          memo[k] = v
        memo
      ),{}
      result

    validate:(attrs)->
      if attrs.label is null or attrs.label is ""
        return "label mustn't be not null"
      if attrs.placeholder is null or attrs.placeholder is ""
        return "placeholder mustn't be not null"
      if attrs.type is null or attrs.type is ""
        return "type mustn't be not null"
      if attrs.position is null or attrs.position < 0
        return "position must be >= 0"
      if attrs.row is null or attrs.row < 0
        return "row must be >= 0"
      if _.isString(attrs.row)
        return "row must be integer"
      if _.isString(attrs.position)
        return "position must be integer"

  DropAreaModel