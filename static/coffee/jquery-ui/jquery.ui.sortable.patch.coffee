(($, undefined_) ->
  $.ui.sortable::_createHelper = (event) ->
    o = @options
    helper = (if $.isFunction(o.helper) then $(o.helper.apply(@element[0], [event, @currentItem])) else ((if o.helper is "clone" then @currentItem.clone() else @currentItem)))

    $((if o.appendTo isnt "parent" then o.appendTo else @currentItem[0].parentNode))[0].appendChild helper[0]  unless helper.parents("body").length
    if helper[0] is @currentItem[0]
      @_storedCSS =
        width: @currentItem[0].style.width
        height: @currentItem[0].style.height
        position: @currentItem.css("position")
        top: @currentItem.css("top")
        left: @currentItem.css("left")
    helper.width @currentItem.width() - 1 if helper[0].style.width is "" or o.forceHelperSize
    helper.height @currentItem.height()  if helper[0].style.height is "" or o.forceHelperSize
    helper
) jQuery