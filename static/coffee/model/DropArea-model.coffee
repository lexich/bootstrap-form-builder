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
      row:0,
      direction:"horizontal"
      size:3

    initialize:->
      LOG "DropAreaModel","initialize"

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
    validate:(attrs, options)->    
      if attrs.label is null or attrs.label is ""
        "label mustn't be not null"
      else if attrs.placeholder is null or attrs.placeholder is ""
        "placeholder mustn't be not null"
      else if attrs.type is null or attrs.type is ""
        "type mustn't be not null"      
      else if attrs.help is null
        "help mustn't be null"
      else if not _.isNumber(attrs.row)
        "row must be integer"
      else if attrs.row < 0
        "row must be >= 0"      
      else if not _.isNumber(attrs.position)
        "position must be integer"
      else if attrs.position < 0
        "position must be >= 0"
      else if attrs.direction not in ["horizontal","vertical"]
        "direction must be [horizontal,vertical]"
      else if not _.isNumber(attrs.size)
        "size must be number"
      else if attrs.size < 1 or attrs.size > 12
        "size must be more then 0 and less or equal then 12"

  DropAreaModel