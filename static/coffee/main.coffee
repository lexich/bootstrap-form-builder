DragView = Backbone.View.extend
  initialize:(options)->
    @$el.draggable
      appendTo:"body"
      helper:"clone"    

DropView = Backbone.View.extend
  initialize:(options)->
    accept = @$el.data("drop-accept")
    @$el.droppable(
      accept: accept
      activeClass:"drag-default"
      hoverClass:"drag-hover"      
      drop:(ev,ui)->
        console.log "drop"
        $("<li>").html(ui.draggable.html()).appendTo(this)
    )
    @$el.sortable()



$(document).ready ->
  dragView = new DragView 
    el:$("*[data-drag-accept]")
  dropView = new DropView 
    el:$("*[data-drop-accept]")

