DATA_VIEW = "$view"
DATA_TYPE = "component-type"
DATA_MODEL = "$model"

LOG = (type,msg)->
	#console.log "#{type} #{msg}"
toInt = (v)-> if v is "" then 0 else parseInt v
isPositiveInt = (v)-> /^\d+$/.test v