define [
  "backbone",
  "underscore"
  "common/Log"
],(Backbone,_, Log)->
  log = Log.getLogger("model/FormItemModel")
  
  FormItemModel = Backbone.Model.extend
    modelname:"FormItemModel"
    defaults:
      label:""
      type:"input"
      name:""
      help:""
      direction:"horizontal"
      position:0
      row:0,
      fieldset:0
      size:3

    initialize:->
      log.info "initialize"

    parse:(attrs, options)->
      log.info "parse"
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
      else if attrs.type is null or attrs.type is ""
        "type mustn't be not null"      
      else if attrs.help is null
        "help mustn't be null"
      else if not _.isNumber(attrs.row)
        "row must be integer"
      else if attrs.direction not in ["horizontal","vertical"]
        "direction must be [horizontal,vertical]"
      else if attrs.row < 0
        "row must be >= 0"      
      else if not _.isNumber(attrs.position)
        "position must be integer"
      else if attrs.position < 0
        "position must be >= 0"
      else if attrs.fieldset < 0
        "fieldset must be >= 0"
      else if not _.isNumber(attrs.size)
        "size must be number"
      else if attrs.size < 1 or attrs.size > 12
        "size must be more then 0 and less or equal then 12"

  FormItemModel