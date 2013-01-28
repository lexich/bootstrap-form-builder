DATA_VIEW = "$view"
DATA_TYPE = "component-type"
DATA_MODEL = "$model"

LOG = (type,msg)->
	if type in ["DropAreaModel"]
  	console.log "#{type} #{msg}"
toInt = (v)-> if v is "" then 0 else parseInt v
isPositiveInt = (v)-> /^\d+$/.test v