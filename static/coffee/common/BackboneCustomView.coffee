define [
  "jquery"
  "underscore"
  "backbone"
  "common/Log"
],($, _, Backbone, Log)->
  log = Log.getLogger("common/CustomView")

  __super__ = Backbone.View

  Backbone.CustomView = Backbone.View.extend
    BIND_VIEW:"_$$CustomViewBinder"
    dragActive: false
    originParent: null

    childrenConnect:(parent,child)->

    constructor: (options)->
      @configureOptions.apply(this,arguments)
      log.info "constructor viewname:#{@viewname}"
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

    handle_create_new:(event,ui)-> this


    getPrevious:(view, factor)->

    getNext:(view)->

    __initPlaceholder:->
      log.info "__initPlaceholder"
      $placeholder = $("> [data-drop-accept-placeholder]", @$el)
      if _.isUndefined($placeholder.data("sortable"))
        $placeholder.sortable
          helper:"original"
          tolerance:"pointer"
          dropOnEmpty:"true"
          placeholder:"ui_formitem__placeholder span3"
          update: (event,ui)=>
            view = @handle_create_new(event,ui)
            view.render()
            view.reindex()
          activate: (event,ui)=>
            @dragActive = true
            true
          deactivate: (event, ui)=>
            @dragActive = false
            true
          over: (event, ui)->
            if $(this).is("[data-drop-accept-placeholder='fieldset']")
                $("[data-ghost-row]")
                  .hide()
            true
      $placeholder

    render:->
      log.info "render #{@viewname}:#{@cid}"
      $holder = $(document.createDocumentFragment())
      $holder.append @$el.children()

      result = __super__::render.apply(this, arguments)
      htmlTemplate = @_getTemplateHtml()
      data = _.result(this,"templateData")
      html = _.template htmlTemplate, data
      @$el.html html
      @__initPlaceholder()
      _.each @childrenViewsOrdered(),(view)=>
        @childrenConnect this, view
        view.render()
      $holder.remove()
      @updateViewModes()
      @$el.find("select,input,textarea").focus -> $(this).blur()
      result

    reindex:->

    updateViewModes:->

    handle_sortable_start:->
      $(@placeholderSelector).show()
      $("body").addClass("ui_draggableprocess")

    handle_sortable_stop:(event,ui)->
      $(@placeholderSelector).hide()
      $("body").removeClass("ui_draggableprocess")
      @reindex()

    checkModel:(log,model)->
      unless model.isValid()
        log.error model.validationError
        false
      else
        true

    remove:->
      log.info "remove #{@cid}"
      if @model? then @collection?.remove @model
      @parentView?.removeChild this
      @parentView?.updateViewModes()

      _.each @childrenViews, (view,k)=>
        @removeChild view
        view.remove()
      __super__::remove.apply(this, arguments)

    createChild:(options)->
      item = new @ChildType(options)
      @addChild item

    addChild:(view)->
      log.info "addChild #{@cid}"
      @childrenViews[view.cid] = view
      view.parentView?.removeChild view
      view.parentView = this
      @updateViewModes()
      view

    removeChild:(view)->
      log.info "removeChild #{@cid}"
      delete @childrenViews[view.cid]
      delete view?.parentView
      if _.size(@childrenViews) is 0
        @remove()
      else
        @updateViewModes()
      view

    setParent:(view)->
      log.info "setParent #{@cid}"
      if @parentView?
        @parentView.removeChild this
      @parentView = view
      view?.childrenViews[this.cid] = this
      view.updateViewModes()
      view

    cleanSpan:($el)->
      if(clazz = $el.attr("class"))
        clazz = clazz.replace(/span\d{1,2}/g,"").replace(/offset\d{1,2}/g,"")
        $el.attr "class", clazz.trim()
      $el


  Backbone