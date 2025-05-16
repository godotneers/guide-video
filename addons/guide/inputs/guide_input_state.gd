## The GUIDEInputState holds the current state of all input. It is basically a wrapper around Godot's Input
## class that provides some additional functionality like getting the information if any key or mouse button
## is currently pressed. It also is the single entry point for all input events from Godot, so we don't have 
## process them in every GUIDEInput object and duplicate input handling code everywere. This also improves performance.
## 
class_name GUIDEInputState

## Device ID for a virtual joystick that means "any joystick".
## This relies on the fact that Godot's device IDs for joysticks are always >= 0.
## https://github.com/godotengine/godot/blob/80a3d205f1ad22e779a64921fb56d62b893881ae/core/input/input.cpp#L1821
const ANY_JOY_DEVICE_ID: int = -1

## Signalled, when the keyboard state has changed.
signal keyboard_state_changed()
## Signalled, when the mouse motion state has changed.
signal mouse_position_changed()
## Signalled, when the mouse button state has changed.
signal mouse_button_state_changed()
## Signalled, when the joy button state has changed.
signal joy_button_state_changed()
## Signalled, when the joy axis state has changed.
signal joy_axis_state_changed()
## Signalled, when the touch state has changed.
signal touch_state_changed()

# Keys that are currently pressed. Key is the key index, value is not important. The presence of a key in the dictionary
# indicates that the key is currently pressed.
var _keys: Dictionary = {}
# Fingers that are currently touching the screen. Key is the finger index, value is the position (Vector2).
var _finger_positions: Dictionary = {}
# The mouse movement since the last frame. 
var _mouse_movement: Vector2 = Vector2.ZERO
# Mouse buttons that are currently pressed. Key is the button index, value is not important. The presence of a key
# in the dictionary indicates that the button is currently pressed.
var _mouse_buttons: Dictionary = {}
# Joy buttons that are currently pressed. Key is device id, value is a dictionary with the button index as key. The 
# value of the inner dictionary is not important. The presence of a key in the inner dictionary indicates that the button 
# is currently pressed.
var _joy_buttons: Dictionary = {}
# Current values of joy axes. Key is device id, value is a dictionary with the axis index as key. 
# The value of the inner dictionary is the axis value. Once an axis is actuated, it will be added to the dictionary.
# We will not remove it anymore after that.
var _joy_axes: Dictionary = {}

# The current mapping of joy index to device id. This is used to map the joy index to the device id. A joy index
# if -1 means "any device id".
var _joy_index_to_device_id: Dictionary = {}

func _init():
	Input.joy_connection_changed.connect(_refresh_joy_device_ids)
	_clear()

# Used by the automated tests to make sure we don't have any leftovers from the 
# last test.
func _clear():
	_keys.clear()
	_finger_positions.clear()
	_mouse_movement = Vector2.ZERO
	_mouse_buttons.clear()
	_joy_buttons.clear()
	_joy_axes.clear()
	
	_refresh_joy_device_ids(0, 0)
	
	# ensure we have an entry for the virtual "any device id"
	_joy_buttons[ANY_JOY_DEVICE_ID] = {}
	_joy_axes[ANY_JOY_DEVICE_ID] = {}
		
	
# Called when any joy device is connected or disconnected. This will refresh the joy device ids and clear out any	
# joy state which is not valid anymore. Will also notify relevant inputs.
func _refresh_joy_device_ids(_ignore1, _ignore2):
	# refresh the joy device ids
	_joy_index_to_device_id.clear()
	var connected_joys:Array[int] = Input.get_connected_joypads()
	for i in connected_joys.size():
		var device_id:int = connected_joys[i]
		_joy_index_to_device_id[i] = device_id
		# ensure we have an inner dictionary for the device id
		# by setting this here, we don't need to check for the device id
		# on every input event
		if not _joy_buttons.has(device_id):
			_joy_buttons[device_id] = {}
		if not _joy_axes.has(device_id):
			_joy_axes[device_id] = {}
	
	# add a virtual device id for the "any device id" case
	_joy_index_to_device_id[-1] = ANY_JOY_DEVICE_ID

	var dirty: bool = false
	
	# clear out any joy state which is not valid anymore
	for device_id in _joy_buttons.keys():
		if device_id != ANY_JOY_DEVICE_ID and not connected_joys.has(device_id):
			dirty = true
			_joy_buttons.erase(device_id)
			
	if dirty:		
		# notify all inputs that the joy state has changed
		joy_button_state_changed.emit()

	dirty = false
	for device_id in _joy_axes.keys():
		if device_id != ANY_JOY_DEVICE_ID and not connected_joys.has(device_id):
			dirty = true
			_joy_axes.erase(device_id)
		
	if dirty:
		# notify all inputs that the joy state has changed
		joy_axis_state_changed.emit()
		
## Called at the end of the frame to reset the state before the next frame.
func _reset() -> void:
	_mouse_movement = Vector2.ZERO


## Processes an input event and updates the state. 
func _input(event: InputEvent) -> void:
	# ----------------------- KEYBOARD -----------------------------
	if event is InputEventKey:
		var index: int = event.physical_keycode

		if event.pressed:
			_keys[index] = true
		else:
			_keys.erase(index)

		# Emit the keyboard state changed signal
		keyboard_state_changed.emit()
		return

	# ----------------------- MOUSE MOVEMENT -----------------------
	if event is InputEventMouseMotion:
		# Emit the mouse moved signal with the distance moved
		_mouse_movement += event.relative
		mouse_position_changed.emit()
		return

	# ----------------------- MOUSE BUTTONS -----------------------		
	if event is InputEventMouseButton:
		var index: int = event.button_index

		if event.pressed:
			_mouse_buttons[index] = true
		else:
			_mouse_buttons.erase(index)

		# Emit the mouse button state changed signal
		mouse_button_state_changed.emit()
		return

	# ----------------------- JOYSTICK BUTTONS -----------------------		
	if event is InputEventJoypadButton:
		var device_id: int = event.device
		var button: int = event.button_index

		if event.pressed:
			# _refresh_joy_device_ids ensures we have an inner dictionary for the device id
			# so we don't need to check for it here
			_joy_buttons[device_id][button] = true
		else:
			_joy_buttons[device_id].erase(button)
	
		# finally set the ANY_JOY_DEVICE_ID state based on what we know
		var any_value: bool = false
		for inner in _joy_buttons.keys():
			if inner != ANY_JOY_DEVICE_ID and _joy_buttons[inner].has(button):
				any_value = true
				break
		
		if any_value:
			_joy_buttons[ANY_JOY_DEVICE_ID][button] = true
		else:
			_joy_buttons[ANY_JOY_DEVICE_ID].erase(button)
			
		# Emit the joy button state changed signal
		joy_button_state_changed.emit()
		return
		
	# ----------------------- JOYSTICK AXES -----------------------		
	if event is InputEventJoypadMotion:
		var device_id: int = event.device
		var axis: int = event.axis

		# update the axis value
		_joy_axes[device_id][axis] = event.axis_value
		
		# for the ANY_JOY_DEVICE_ID, we apply the maximum actuation of all devices (in any direction)
		var any_value: float = 0.0
		var maximum_actuation: float = 0.0
		for inner in _joy_axes.keys():
			if inner != ANY_JOY_DEVICE_ID and _joy_axes[inner].has(axis):
				var strength: float = abs(_joy_axes[inner][axis])
				if strength > maximum_actuation:
					maximum_actuation = strength
					any_value = _joy_axes[inner][axis]

		_joy_axes[ANY_JOY_DEVICE_ID][axis] = any_value
		
		# Emit the joy axis state changed signal
		joy_axis_state_changed.emit()
		return

	# ----------------------- TOUCH INPUT -----------------------

	if event is InputEventScreenTouch:
		if event.pressed:
			_finger_positions[event.index] = event.position
		else:
			_finger_positions.erase(event.index)
			
		touch_state_changed.emit()
		return
		
		
	if event is InputEventScreenDrag:
		_finger_positions[event.index] = event.position

		touch_state_changed.emit()
		return

		
## Returns true if the key with the given index is currently pressed.
func is_key_pressed(key: Key) -> bool:
	return _keys.has(key)
	
# Returns true if at least one key in the given array is currently pressed.
func is_at_least_one_key_pressed(keys:Array[Key]) -> bool:	
	for key in keys:
		if _keys.has(key):
			return true
	return false

# Returns true if all keys in the given array are currently pressed.
func are_all_keys_pressed(keys:Array[Key]) -> bool:
	return _keys.has_all(keys)

## Returns true if currently any key is pressed.
func is_any_key_pressed() -> bool:
	return not _keys.is_empty()

## Gets the mouse movement since the last frame.
## If no movement has been detected, returns Vector2.ZERO.
func get_mouse_delta_since_last_frame() -> Vector2:
	return _mouse_movement
	
## Returns the current mouse position in the root viewport.
func get_mouse_position() -> Vector2:
	return Engine.get_main_loop().root.get_mouse_position()

	
## Returns true if the mouse button with the given index is currently pressed.	
func is_mouse_button_pressed(button_index: MouseButton) -> bool:
	return _mouse_buttons.has(button_index)

## Returns true if currently any mouse button is pressed.
func is_any_mouse_button_pressed() -> bool:
	return not _mouse_buttons.is_empty()
	
## Returns the current value of the given joy axis on the device with the given index. If no
## such device or axis exists, returns 0.0.
func get_joy_axis_value(index:int, axis:JoyAxis) -> float:
	var device_id: int = _joy_index_to_device_id.get(index, -9999)
	# unknown device
	if device_id == -9999:
		return 0.0
	if _joy_axes.has(device_id):
		var inner = _joy_axes[device_id]
		return inner.get(axis, 0.0)
	return 0.0

## Returns true, if the given joy button is currentely pressed on the device with the given index.
func is_joy_button_pressed(index:int, button:JoyButton) -> bool:	
	var device_id: int = _joy_index_to_device_id.get(index, -9999)
	# unknown device
	if device_id == -9999:
		return false
	if _joy_buttons.has(device_id):
		return _joy_buttons[device_id].has(button)
	return false

## Returns true, if currently any joy button is pressed on any device.	
func is_any_joy_button_pressed() -> bool:
	for inner in _joy_buttons.values():
		if not inner.is_empty():
			return true
	return false
	
## Returns true if currently any joy axis is actuated with at least the given strength.
func is_any_joy_axis_actuated(minimum_strength: float) -> bool:
	for inner in _joy_axes.values():
		for value in inner.values():
			if abs(value) >= minimum_strength:
				return true
	return false

## Gets the finger position of the finger at the given index.
## If finger_index is < 0, returns the average of all finger positions.
## Will only return a position if the amount of fingers
## currently touching matches finger_count. 
##
## If no finger position can be determined, returns Vector2.INF.
func get_finger_position(finger_index: int, finger_count: int) -> Vector2:
	# if we have no finger positions right now, we can cut it short here
	if _finger_positions.is_empty():
		return Vector2.INF

	# If the finger count doesn't match we have no position right now
	if _finger_positions.size() != finger_count:
		return Vector2.INF

	# if a finger index is set, use this fingers position, if available
	if finger_index > -1:
		return _finger_positions.get(finger_index, Vector2.INF)

	var result: Vector2 = Vector2.ZERO
	for value in _finger_positions.values():
		result += value

	result /= float(finger_count)
	return result
	
## Returns true, if currently any finger is touching the screen.	
func is_any_finger_down() -> bool:
	return not _finger_positions.is_empty()

	
