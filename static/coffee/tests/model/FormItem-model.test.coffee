define [
  "model/FormItem-model"
],(FormItemModel)->

  describe "FormItemModel",->
    beforeEach ->
      @model = new FormItemModel
    
    it "default init",->
      expect(@model.get("position")).toEqual(0)
      expect(@model.get("row")).toEqual(0)
      expect(@model.get("label")).toEqual("")
      expect(@model.get("placeholder")).toEqual("")
      expect(@model.get("type")).toEqual("input")
      expect(@model.get("name")).toEqual("")
      expect(@model.get("help")).toEqual("")
      expect(@model.get("direction")).toEqual("horizontal")
      expect(@model.get("size")).toEqual(3)


    it "initialization",->
      @model.set
        label:"test1"
        placeholder:"test2"
        type:"test3"
        name:"test4"
        help:"test5"
        position:1
        row:2
        direction:"vertical"
      ,{validate:true}
      expect(@model.validationError).toBeNull()
      expect(@model.get("position")).toEqual(1)
      expect(@model.get("row")).toEqual(2)
      expect(@model.get("label")).toEqual("test1")
      expect(@model.get("placeholder")).toEqual("test2")
      expect(@model.get("type")).toEqual("test3")
      expect(@model.get("name")).toEqual("test4")
      expect(@model.get("help")).toEqual("test5")
      expect(@model.get("direction")).toEqual("vertical")

    it "validate",->      
      @model.set
        label:"test1"
        placeholder:"test2"
        type:"test3"
        name:"test4"
        help:"test5"
        position:1
        row:2
        direction:"vertical"      
      expect(@model.validationError).not.toBeDefined()
      error = @model.validationError

      @model.set label:"",{validate:true}
      expect(@model.validationError).toBeDefined()
      expect(@model.validationError.length).toBeGreaterThan(1)
      error = @model.validationError

      @model.set label:null,{validate:true}
      expect(@model.validationError).toEqual(error)
      error = @model.validationError

      @model.set placeholder:"",{validate:true}
      expect(@model.validationError).not.toEqual(error)
      error = @model.validationError

      @model.set placeholder:null,{validate:true}
      expect(@model.validationError).toEqual(error)
      error = @model.validationError

      @model.set type:"",{validate:true}
      expect(@model.validationError).not.toEqual(error)
      error = @model.validationError

      @model.set type:null,{validate:true}
      expect(@model.validationError).toEqual(error)
      error = @model.validationError

      @model.set name:"",{validate:true}
      expect(@model.validationError).not.toEqual(error)
      error = @model.validationError

      @model.set name:null,{validate:true}
      expect(@model.validationError).toEqual(error)
      error = @model.validationError

      @model.set help:"",{validate:true}
      expect(@model.validationError).toBeNull()
      error = @model.validationError

      @model.set help:null,{validate:true}
      expect(@model.validationError).not.toEqual(error)
      error = @model.validationError

      @model.set position:"",{validate:true}
      expect(@model.validationError).not.toEqual(error)
      error = @model.validationError

      @model.set position:null,{validate:true}
      expect(@model.validationError).toEqual(error)
      error = @model.validationError

      @model.set position:-1,{validate:true}
      expect(@model.validationError).not.toBeNull()
      error = @model.validationError

      @model.set position:0,{validate:true}
      expect(@model.validationError).toBeNull()
      error = @model.validationError

      @model.set row:"",{validate:true}
      expect(@model.validationError).not.toEqual(error)
      error = @model.validationError

      @model.set row:null,{validate:true}
      expect(@model.validationError).toEqual(error)
      error = @model.validationError

      @model.set row:-1,{validate:true}
      expect(@model.validationError).not.toBeNull()
      error = @model.validationError

      @model.set row:0,{validate:true}
      expect(@model.validationError).toBeNull()
      error = @model.validationError

      @model.set direction:"",{validate:true}      
      expect(@model.validationError).not.toBeNull()
      error = @model.validationError

      @model.set name:"vertical",{validate:true}
      expect(@model.validationError).toBeNull()

      @model.set name:"horizontal",{validate:true}
      expect(@model.validationError).toBeNull()
      
      expect(@model.set size:0,{validate:true}).toBeFalsy()
      expect(@model.set size:13,{validate:true}).toBeFalsy()
      expect(@model.set size:1,{validate:true}).toBeTruthy()