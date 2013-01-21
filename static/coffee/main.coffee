
DragView = Backbone.View.extend  
  initialize:(options)->
    @$el.draggable
      appendTo:"body"
      helper:"clone"

DropView = Backbone.View.extend
  events:
    "click *[data-js-close]": "event_close"
  initialize:(options)->
    accept = @$el.data("drop-accept")
    @$el.droppable(
      accept: accept
      activeClass:"drag-default"
      hoverClass:"drag-hover"      
      drop:(ev,ui)->
        console.log "drop"
        $item = $("<li>").addClass("form-item").html(ui.draggable.html())
        $(this).find(".placeholder").before $item
    )
    @$el.sortable()
  event_close:(e)->
    $(e.target).parent().remove()



$(document).ready ->
  dragView = new DragView 
    el:$("*[data-drag-accept]")
  dropView = new DropView 
    el:$("*[data-drop-accept]")

