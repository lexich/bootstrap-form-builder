define [
 "backbone"
  "underscore"
 "common/BackboneCustomView"
],(Backbone,_)->

  CustomView = Backbone.CustomView.extend
    viewname:"customView"
    ChildType: Backbone.CustomView.extend viewname:"customchild"

  describe "BackboneCustomView",->
    beforeEach ->
      if $("#tmplPath").length < 1
        $("body").append $("<script type='text/template' id='tmplPath'>")

      @tmpl = "<div>CustomView</div>"
      $("#tmplPath").text @tmpl
      @view = new CustomView
        templatePath:"#tmplPath"

    it "constructor",->
      expect(@view.templatePath).toEqual("#tmplPath")

    it "expect Throw",->
      expect(-> new Backbone.CustomView).toThrow(new Error("Need this.viewname attribute"))

    it "render",->
      @view.render()
      expect(@view.$el.html()).toEqual(@tmpl)

    it "createChild",->
      view = @view.createChild({})
      view2 = @view.createChild({})
      expect(view.parentView.cid).toEqual(@view.cid)
      childrens = _.keys(@view.childrenViews)
      expect(childrens.length).toEqual(2)
      expect([view.cid,view2.cid]).toContain(childrens[0])
      expect([view.cid,view2.cid]).toContain(childrens[1])

      @view.removeChild(view2)
      expect(_.keys(@view.childrenViews).length).toEqual(1)
      expect(view2.parentView).toEqual(null)
      expect(view.parentView.cid).toEqual(@view.cid)

      @view.addChild(view2)
      expect(_.keys(@view.childrenViews).length).toEqual(2)
      expect(view2.parentView.cid).toEqual(@view.cid)
      expect(view.parentView.cid).toEqual(@view.cid)

      view.setParent view2
      expect(view.parentView.cid).toEqual(view2.cid)
      expect(_.keys(view2.childrenViews).length).toEqual(1)
      expect(_.keys(view2.childrenViews)[0]).toEqual(view.cid)
      expect(_.keys(@view.childrenViews).length).toEqual(1)
      expect(_.keys(@view.childrenViews)[0]).toEqual(view2.cid)

    it "recursive render",->
      view = @view.createChild(templatePath:"#tmplPath")
      view2 = @view.createChild(templatePath:"#tmplPath")
      bRender = false
      bRender2 = false
      view.render = -> bRender = true
      view2.render = -> bRender2 = true
      @view.childrenConnect = (parent,child)->
        child.$el.appendTo parent.$el
      @view.render()
      expect(bRender).toBeTruthy()
      expect(bRender2).toBeTruthy()
      expect(@view.$el.html()).toEqual("<div>CustomView</div><div></div><div></div>")

