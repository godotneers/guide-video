@tool
class_name GUIDEVirtualStick
extends Node2D

var _touch_input:GUIDEInputTouchAxis2D = GUIDEInputTouchAxis2D.new()

@export var interaction_zone:float = 200:
	set(value):
		interaction_zone = value
		queue_redraw()
		
@export var stick_size:float = 100:
	set(value):
		stick_size = value
		queue_redraw()
		
func _input(event):
	_touch_input._input(event)
	
	
func _process(delta):
	var narf = InputEventJoypadMotion.new()
	narf.axis = JOY_AXIS_LEFT_X
	narf.axis_value = 0.32
	
	
	Input.parse_input_event(narf)
		
	var narf2 = InputEventJoypadMotion.new()
	narf2.axis = JOY_AXIS_LEFT_Y
	narf2.axis_value = 0.32
	
	Input.parse_input_event(narf2)
		
func _draw():
	draw_circle(Vector2.ZERO, interaction_zone, Color(0.5, 0.5, 1.0, 0.5))
	draw_circle(Vector2.ZERO, stick_size, Color(0.9, 0.9, 0.3, 0.5))
