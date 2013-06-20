define [
  "backbone"
],(Backbone)->
  FieldsetModel = Backbone.Model.extend
    modelname:"FieldsetModel"
    defaults:
      fieldset:0
      title:"Название"
      direction:"horizontal"
      extention:""
      extentiondata:[
        {id:"one",text:"Один"}
        {id:"two",text:"Два"}
      ]
      filter:""
    validate:(attrs, options)->
      if attrs.fieldset < 0
        "row must be >= 0"
      else if attrs.title == null or attrs.title == ""
        "title must be not empty"
      else if attrs.direction not in ["horizontal","vertical"]
        "direction must be [horizontal,vertical]"
      else if attrs.extention not in ["", "multiinput", "multitypeinput"]
        "extention doesn't valid"
      else if not _.isArray(attrs.extentiondata)
        "extentiondata must be array"

    get_template_config:->
      title:
        type:"input"
        title:"Заголовок"
      extention:
        type:"select"
        title:"Расширение"
        data:
          data:[
            {id:"multiinput", text:"multiinput"}
            {id:"multitypeinput", text:"multitypeinput"}
          ]
          allowClear: true
          placeholder:"Выберите тип"
      direction:
        type:"select"
        title:"Направление"
        data:[
          {id:"horizontal",text:"горизонтальное"}
          {id:"vertical",text:"вертикальное"}
        ]
      filter:
        type:"select"
        title:"Фильтр"
        data:
          data:@get("extentiondata")
          allowClear: true
          placeholder:"Выберите тип"

  FieldsetModel