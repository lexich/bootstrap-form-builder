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
      LOG "CustomView","constructor viewname:#{@viewname}"
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
        viewname:""
        placeholderSelector:"[data-drop-accept-placeholder]"
        _itemsSelectorsCache:{}
        _getTemplateHtml_Cache:""
        parentView:null
        childrenViews:{}
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
      if selector? then $(selector,@$el)

    childrenViewsOrdered:-> _.values(@childrenViews)

    handle_create_new:(event,ui)->

    __initPlaceholder:->
      LOG "CustomView","__initPlaceholder"
      $placeholder = $("> [data-drop-accept-placeholder]", @$el)
      if _.isUndefined($placeholder.data("sortable"))
        $placeholder.sortable
          helper:"original"
          tolerance:"pointer"
          dropOnEmpty:"true"
          update: (event,ui)=>@handle_create_new(event,ui).render()
      $placeholder

    render:->
      $holder = $(document.createDocumentFragment())
      $holder.append @$el.children()

      result = Backbone.View::render.apply(this, arguments)
      htmlTemplate = @_getTemplateHtml()
      data = _.result(this,"templateData")
      html = _.template htmlTemplate, data
      @$el.html html
      @__initPlaceholder()
      _.each @childrenViewsOrdered(),(view)=>
        @childrenConnect this, view
        view.render()
      $holder.remove()
      result

    reindex:->

    handle_sortable_start:->
      $(@placeholderSelector).show()

    handle_sortable_stop:(event,ui)->
      $(@placeholderSelector).hide()
      @reindex()

    remove:->
      @parentView?.removeChild this
      _.each @childrenViews, (view,k)->
        @removeChild view
        view.remove()
      @model?.destroy()
      Backbone.View::remove.apply(this, arguments)

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
      if _.size(@childrenViews) is 0
        @remove()
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