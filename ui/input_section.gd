@tool
class_name InputSection
extends PanelContainer

@onready var _title:Label = %Title

@export var title:String:
	set(value):
		title = value
		_refresh()
		
func _ready():
	_refresh()
	
func _refresh():
	if not is_node_ready():
		return
		
	_title.text = title

