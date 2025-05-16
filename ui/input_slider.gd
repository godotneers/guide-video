@tool
class_name InputSlider
extends HBoxContainer

signal changed(new_value:int)

@onready var _title:Label = %Title
@onready var _value:HSlider = %Value

@export var title:String:
	set(value):
		title = value
		_refresh()
		
@export var value:int:
	set(val):
		value = val
		_refresh()
		
@export var min_value:int = 1: 
	set(value):
		min_value = value
		_refresh()
		
@export var max_value:int = 10: 
	set(value):
		max_value = value
		_refresh()
		
func _ready():
	_value.value_changed.connect(func(val): value = round(value); changed.emit(value))
	_refresh()	


func _refresh():
	if not is_node_ready():
		return
		
	_title.text = title
	_value.set_value_no_signal(value)
	_value.min_value = min_value
	_value.max_value = max_value
	_value.step = 1
	_value.rounded = true
