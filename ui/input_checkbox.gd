@tool
class_name InputCheckbox
extends HBoxContainer

signal toggled(new_value:bool)

@onready var _title:Label = %Title
@onready var _checked:CheckBox = %Checked

@export var title:String:
	set(value):
		title = value
		_refresh()
		
@export var checked:bool:
	set(value):
		checked = value
		_refresh()
		
		
func _ready():
	_checked.toggled.connect(func(val): checked = val; toggled.emit(val))
	_refresh()	


func _refresh():
	if not is_node_ready():
		return
		
	_title.text = title
	_checked.set_pressed_no_signal(checked)
