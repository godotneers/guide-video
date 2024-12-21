## Input that triggers if any input from the given device class
## is given. Only looks for button inputs, not axis inputs as axes
## have a tendency to accidentally trigger.
@tool
class_name GUIDEInputAny
extends GUIDEInput

## Should input from the mouse be considered?
@export var mouse:bool = false

## Should input from gamepads/joysticks be considered?
@export var joy:bool = false

## Should input from the keyboard be considered?
@export var keyboard:bool = false


func _needs_reset() -> bool:
	# Needs reset because we cannot detect the absence of input.
	return true

func _input(event:InputEvent):
	if mouse and event is InputEventMouseButton:
		_value = Vector3.RIGHT
		return
			
	if joy and event is InputEventJoypadButton:
		_value = Vector3.RIGHT
		return 
			
	if keyboard and event is InputEventKey:
		_value = Vector3.RIGHT
		return
		
	_value = Vector3.ZERO		


func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInput and \
		other.mouse == mouse and \
		other.joy == joy and \
		other.keyboard == keyboard 

func _editor_name() -> String:
	return "Any Input"
	
	
func _editor_description() -> String:
	return "Input that triggers if any input from the given device class is given."
	
	
func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.BOOL
