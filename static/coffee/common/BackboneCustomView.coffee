define [
  "jquery"
  "underscore"
  "backbone"
  "common/Log"
],($, _, Backbone, Log)->
  log = Log.getLogger("common/CustomView")

  __super__ = Backbone.View
  $bufferDocumentFragment = $(document.createDocumentFragment())

  Backbone.CustomView = Backbone.View.extend
    #Constant value, key of data-attribute of DOM element,
    #reference to this view
    BIND_VIEW:"_$$CustomViewBinder"

    #Placeholder flag describe dragging state
    dragActive: false

    # Type of children elements
    ChildType:Backbone.CustomView

    # mapper of DOM elements, that contains in $el
    # key/value - alias/jQuery-selector
    itemsSelectors:{}

    # name of current view
    viewname:null

    ###
    @constructor
    @param options - arguments
    ###
    constructor: (options)->
      unless @viewname?
        throw "Need this.viewname attribute"

      @configureOptions.apply(this,arguments)
      log.info "constructor viewname:#{@viewname}"
      Backbone.View.call(this, options)
      @$el.data Backbone.CustomView::BIND_VIEW, this
      this

    ###
    configure options after create instance of this View
    ###
    configureOptions: (options)->
      mixin =
        templatePath:null
        templateData:-> @model?.toJSON() ? {}
        placeholderSelector:"[data-drop-accept-placeholder]"
        parentView:null
        childrenViews:{}

      options = _.pick(options or {}, _.keys(mixin))
      _.extend this, options
      _.defaults this, mixin

    ###
    Handler connect this view with children views
    @param parent - pointer to this view
    @param child - child view
    ###
    childrenConnect:(parent,child)->

    ###
    Helper to extract view frim DOM element
    ###
    staticViewFromEl:(el)-> $(el).data Backbone.CustomView::BIND_VIEW

    ###
    Handler for reinit current conmonent, usualy change children state
    need overwrite in children Views prototype
    ###
    reinitialize:->

    ###
    Return html template of current view, from DOM document
    where this.teplatePath pointer to id of element
    <script id="{this.teplatePath}" type="text/template">TEMPLATE</script>
    @return {string} html teplate
    ###
    _getTemplateHtml:->
      if @_getTemplateHtml_Cache? and @_getTemplateHtml_Cache!=""
        return @_getTemplateHtml_Cache
      return unless @templatePath?
      tmpl = @templatePath.trim()
      @_getTemplateHtml_Cache = $("#{tmpl}[type='text/template']:first").html()
      return @_getTemplateHtml_Cache ? ""

    ###
    Get inner DOM el, where name if key of itemsSelectors dictionary
    @return {DOM} inner DOM element
    ###
    getItem:(name)->
      selector = @itemsSelectors[name]
      if selector? then $(selector,@$el)

    ###
    Helper for order children views, for overwriting in children View prototypes
    @return ordered children views
    ###
    childrenViewsOrdered:-> _.values(@childrenViews)

    ###
    Handler for create new children view, using jQuery.ui drag & drop mechanism
    ###
    handle_create_new:(event,ui)-> this

    ###
    Method for init external placeholder for drag & drop
    @return placeholder
    ###
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
                $(this)
                  .sortable "refreshPositions"
            true
      $placeholder

    ###
    Overwrite Backbone.View
    ###
    render:->
      log.info "render #{@viewname}:#{@cid}"
      $bufferDocumentFragment.append @$el.children()

      result = __super__::render.apply(this, arguments)
      htmlTemplate = @_getTemplateHtml()
      data = _.result(this,"templateData")
      html = _.template htmlTemplate, data
      @$el.html html
      @__initPlaceholder()
      _.each @childrenViewsOrdered(),(view)=>
        @childrenConnect this, view
        view.render()
      @updateViewModes()
      @$el.find("select,input,textarea").focus -> $(this).blur()
      result

    ###
    Helper for reinder children components
    ###
    reindex:->

    ###
    Helper for update view
    ###
    updateViewModes:->

    ###
    jQuery.ui sortable start handler
    ###
    handle_sortable_start:->
      $(@placeholderSelector).show()
      $("body").addClass("ui_draggableprocess")

    ###
    jQuery.ui sortable start handler
    ###
    handle_sortable_stop:(event,ui)->
      $(@placeholderSelector).hide()
      $("body").removeClass("ui_draggableprocess")
      @reindex()

    ###
    helper for check model
    ###
    checkModel:(log,model)->
      unless model.isValid()
        log.error model.validationError
        false
      else
        true

    ###
    Overwrite Backbone.View
    ###
    remove:->
      log.info "remove #{@cid}"
      if @model? then @collection?.remove @model
      @parentView?.removeChild this
      @parentView?.updateViewModes()

      _.each @childrenViews, (view,k)=>
        @removeChild view
        view.remove()
      __super__::remove.apply(this, arguments)

    ###
    Helper for create child view
    @return child view
    ###
    createChild:(options)->
      item = new @ChildType(options)
      @addChild item

    ###
    Helper for add child view
    @return adding view
    ###
    addChild:(view)->
      log.info "addChild #{@cid}"
      @childrenViews[view.cid] = view
      view.parentView?.removeChild view
      view.parentView = this
      @updateViewModes()
      view

    ###
    Helper remove children view
    @return removing view
    ###
    removeChild:(view)->
      log.info "removeChild #{@cid}"
      delete @childrenViews[view.cid]
      delete view?.parentView
      if _.size(@childrenViews) is 0
        @remove()
      else
        @updateViewModes()
      view

    ###
    Helper for set parent view
    ###
    setParent:(view)->
      log.info "setParent #{@cid}"
      if @parentView?
        @parentView.removeChild this
      @parentView = view
      view?.childrenViews[this.cid] = this
      view.updateViewModes()
      view

    ###
    Clear DOM element from span* and offset* classes
    ###
    cleanSpan:($el)->
      if(clazz = $el.attr("class"))
        clazz = clazz.replace(/span\d{1,2}/g,"").replace(/offset\d{1,2}/g,"")
        $el.attr "class", clazz.trim()
      $el


  Backbone