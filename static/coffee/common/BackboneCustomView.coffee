define [
  "jquery"
  "underscore",
  "backbone",

],(
  $, _, Backbone
)->
  Backbone.CustomView = Backbone.View.extend
    BIND_VIEW:"_$$CustomViewBinder"

    childrenConnect:(parent,child)->

    constructor: (options)->
      @configureOptions.apply(this,arguments)
      Backbone.View.call(this, options);
      @$el.data Backbone.CustomView::BIND_VIEW, this
      this

    staticViewFromEl:(el)-> $(el).data Backbone.CustomView::BIND_VIEW

    configureOptions: (options)->
      mixin =
        templatePath:null
        templatePathCache:true
        templateData:-> @model?.toJSON() ? {}
        itemsSelectors:{}

        _itemsSelectorsCache:{}
        _getTemplateHtml_Cache:""
        parentView:null
        childrenViews:{}
        models:[]
        ChildType:Backbone.CustomView

      options = _.pick(options or {}, _.keys(mixin))
      _.extend this, options
      _.defaults this, mixin

    reinitialize:->

    _getTemplateHtml:->
      if @templatePathCache and @_getTemplateHtml_Cache? and @_getTemplateHtml_Cache!=""
        return @_getTemplateHtml_Cache
      return unless @templatePath?
      tmpl = @templatePath.trim()
      @_getTemplateHtml_Cache = $("#{tmpl}[type='text/template']:first").html()
      return @_getTemplateHtml_Cache ? ""

    getItem:(name)->
      selector = @itemsSelectors[name]
      if selector? then $(selector,@$el) else @$el

    childrenViewsOrdered:-> _.values(@childrenViews)

    render:->
      @$el.empty()
      result = Backbone.View::render.apply(this, arguments)
      htmlTemplate = @_getTemplateHtml()
      data = _.result(this,"templateData")
      html = _.template htmlTemplate, data
      @$el.html html
      _.each @childrenViewsOrdered(),(view)=>
        @childrenConnect this, view
        view.render()

      result

    destroy:->
      result = Backbone.View::destroy.apply(this, arguments)
      @parentView?.removeChild this
      _.each @childrenViews, (view,k)->
        @removeChild view
        view.destroy()

      result

    createChild:(options)->
      item = new @ChildType(options)
      @addChild item

    addChild:(view)->
      @childrenViews[view.cid] = view
      view?.parentView = this
      view

    removeChild:(view)->
      delete @childrenViews[view.cid]
      delete view?.parentView
      view

    setParent:(view)->
      if @parentView?
        @parentView.removeChild this
      @parentView = view
      view?.childrenViews[this.cid] = this
      view

    callChild:(action, args)->
      _.each @childrenViews, (view,k)=>
        if (func = view[action]) then func.apply view, args


  Backbone