@tool
## Helper node for detecting inputs. Detects the next input matching a specification and 
## emits a signal with the detected input. 
class_name GUIDEInputDetector
extends Node

## A countdown between initiating a dection and the actual start of the 
## detection. This is useful because when the user clicks a button to
## start a detection, we want to make sure that the player is actually
## ready (and not accidentally moves anything). If set to 0, no countdown
## will be started.
@export_range(0, 2, 0.1, "or_greater") var detection_countdown_seconds:float = 0.5

## Minimum amplitude to detect any axis. 
@export_range(0, 1, 0.1, "or_greater") var minimum_axis_amplitude:float = 0.2

## Emitted when the detection has started (e.g. countdown has elapsed).
## Can be used to signal this to the player.
signal detection_started()

## Emitted when the input detector detects an input of the given type.
## If detection was aborted the given input is null.
signal input_dectected(input:GUIDEInput)

# The timer for the detection countdown.
var _timer:Timer

func _ready():
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer, false, Node.INTERNAL_MODE_FRONT)
	_timer.timeout.connect(_begin_detection)

var _is_detecting:bool
var _value_type:GUIDEAction.GUIDEActionValueType

## Detects a boolean input type.
func detect_bool() -> void:
	detect(GUIDEAction.GUIDEActionValueType.BOOL)


## Detects a 1D axis input type.
func detect_axis_1d() -> void:
	detect(GUIDEAction.GUIDEActionValueType.AXIS_1D)

	
## Detects a 2D axis input type.
func detect_axis_2d() -> void:
	detect(GUIDEAction.GUIDEActionValueType.AXIS_2D)


## Detects a 3D axis input type.
func detect_axis_3d() -> void:
	detect(GUIDEAction.GUIDEActionValueType.AXIS_3D)


## Aborts a running detection. If no detection currently runs
## does nothing.
func abort_detection() -> void:
	_timer.stop()
	if _is_detecting:
		_is_detecting = false
		input_dectected.emit(null)

## Detects the given input type.
func detect(value_type:GUIDEAction.GUIDEActionValueType) -> void:
	abort_detection()
	_value_type = value_type
	_timer.start(detection_countdown_seconds)


func _begin_detection():
	_is_detecting = true
	detection_started.emit()


func _input(event:InputEvent) -> void:
	if not _is_detecting:
		return
		
		
	match _value_type:
		GUIDEAction.GUIDEActionValueType.BOOL:
			_try_detect_bool(event)
		GUIDEAction.GUIDEActionValueType.AXIS_1D:
			_try_detect_axis_1d(event)
		GUIDEAction.GUIDEActionValueType.AXIS_2D:
			_try_detect_axis_2d(event)
		GUIDEAction.GUIDEActionValueType.AXIS_3D:
			_try_detect_axis_3d(event)

			
func _try_detect_bool(event:InputEvent) -> void:
	if event is InputEventKey and event.is_released():
		var result := GUIDEInputKey.new()
		result.key = event.physical_keycode
		result.shift = event.shift_pressed
		result.control = event.ctrl_pressed
		result.meta = event.meta_pressed
		result.alt = event.alt_pressed
		_deliver(result)
		return
		
	if event is InputEventMouseButton and event.is_released():
		var result := GUIDEInputMouseButton.new()
		result.button = event.button_index
		_deliver(result)
		return
		
	if event is InputEventJoypadButton and event.is_released():
		var result := GUIDEInputJoyButton.new()
		result.button = event.button_index
		result.joy_index = _find_joy_index(event.device)
		_deliver(result)
		
		
func _try_detect_axis_1d(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		var result := GUIDEInputMouseAxis1D.new()
		# Pick the direction in which the mouse was moved more.
		if abs(event.relative.x) > abs(event.relative.y):
			result.axis	= GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.X 
		else:
			result.axis	= GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.Y
		_deliver(result)
		return

	if event is InputEventJoypadMotion:
		if abs(event.axis_value) < minimum_axis_amplitude:
			return
			
		var result := GUIDEInputJoyAxis1D.new()
		result.axis = event.axis
		result.joy_index = _find_joy_index(event.device)
		_deliver(result)
		
			
func _try_detect_axis_2d(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		var result := GUIDEInputMouseAxis2D.new()
		_deliver(result)
		return
		
	if event is InputEventJoypadMotion:
		if event.axis_value < minimum_axis_amplitude:
			return

		var result := GUIDEInputJoyAxis2D.new()
		match event.axis:
			JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
				result.x = JOY_AXIS_LEFT_X
				result.y = JOY_AXIS_LEFT_Y
			JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
				result.x = JOY_AXIS_RIGHT_X
				result.y = JOY_AXIS_RIGHT_Y
			_:
				# not supported for detection
				return
		result.joy_index = _find_joy_index(event.device)
		_deliver(result)
		return
			

func _try_detect_axis_3d(event:InputEvent) -> void:
	# currently no input for 3D
	pass		


func _find_joy_index(device_id:int) -> int:
	var pads := Input.get_connected_joypads()
	for i in pads.size():
		if pads[i] == device_id:
			return i
			
	return -1

func _deliver(input:GUIDEInput) -> void:
	_is_detecting = false
	input_dectected.emit(input)
