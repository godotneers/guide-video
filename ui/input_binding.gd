@tool
class_name InputBinding
extends HBoxContainer

signal binding_change_requested()

@onready var _title:Button = %TitleButton
@onready var _bound_input:RichTextLabel = %BoundInput

@export var title:String:
	set(value):
		title = value
		_refresh()
		
@export var bound_input:String:
	set(value):
		bound_input = value
		_refresh()
		
		
func _ready():
	_refresh()	
	_title.pressed.connect(func(): binding_change_requested.emit())
	

func _refresh():
	if not is_node_ready():
		return
		
	_title.text = title
	_bound_input.text = bound_input
