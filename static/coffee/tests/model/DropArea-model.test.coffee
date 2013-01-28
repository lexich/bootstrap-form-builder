define [
  "model/DropArea-model"
],(DropAreaModel)->

  describe "AdminCode",->
    beforeEach ->
      @model = new DropAreaModel
    
    it "default init",->
      expect(@model.get("position")).toEqual(0)
      expect(@model.get("row")).toEqual(0)
      expect(@model.get("label")).toEqual("")
      expect(@model.get("placeholder")).toEqual("")
      expect(@model.get("type")).toEqual("input")
      expect(@model.get("name")).toEqual("")
      expect(@model.get("help")).toEqual("")

    it "initialization",->
      @model.set
        label:"test1"
        placeholder:"test2"
        type:"test3"
        name:"test4"
        help:"test5"
        position:1
        row:2
      expect(@model.get("position")).toEqual(1)
      expect(@model.get("row")).toEqual(2)
      expect(@model.get("label")).toEqual("test1")
      expect(@model.get("placeholder")).toEqual("test2")
      expect(@model.get("type")).toEqual("test3")
      expect(@model.get("name")).toEqual("test4")
      expect(@model.get("help")).toEqual("test5")      