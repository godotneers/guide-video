@tool
extends MarginContainer
const InputBindingScene:PackedScene = preload("input_binding.tscn")
const InputSectionScene:PackedScene = preload("input_section.tscn")
# the global contexts
@export var global_keyboard_and_mouse:GUIDEMappingContext
@export var global_controller:GUIDEMappingContext
# the walk mode contexts
@export var walk_mode_keyboard_and_mouse:GUIDEMappingContext
@export var walk_mode_controller:GUIDEMappingContext
# and the build mode contexts
@export var build_mode_keyboard_and_mouse:GUIDEMappingContext
@export var build_mode_controller:GUIDEMappingContext

@export var toggle_settings_dialog:GUIDEAction

@onready var _tab_container:TabContainer = %TabContainer
@onready var _keyboard_and_mouse_container:Container = %KeyboardMouse
@onready var _controller_container:Container = %Controller
@onready var _input_prompt:Container = %InputPrompt
@onready var _input_detector:GUIDEInputDetector = %InputDetector


var _remapper:GUIDERemapper = GUIDERemapper.new()
var _guide_input_formatter:GUIDEInputFormatter = GUIDEInputFormatter.new(48)


func _ready():
	_tab_container.set_tab_title(0, "Keyboard & Mouse" )
	toggle_settings_dialog.triggered.connect(_toggle_visibility)
	
func _toggle_visibility():
	visible = not visible	
	
	if not visible:
		var new_config:GUIDERemappingConfig = _remapper.get_mapping_config()
		RemappingConfiguration.save(new_config)
		GUIDE.set_remapping_config(new_config)
		return
		
	if GUIDE.is_mapping_context_enabled(global_keyboard_and_mouse):
		_tab_container.current_tab = 0
	else:
		_tab_container.current_tab = 1
		
	_tab_container.get_tab_bar().grab_focus()
		
	var remapping_config:GUIDERemappingConfig = RemappingConfiguration.get_current()
		
	_remapper.initialize([
		global_keyboard_and_mouse,
		global_controller,
		walk_mode_keyboard_and_mouse,
		walk_mode_controller,
		build_mode_keyboard_and_mouse,
		build_mode_controller
	], remapping_config)	
	
	_clear(_keyboard_and_mouse_container)
	_clear(_controller_container)
	
	_build_section(_keyboard_and_mouse_container, "Walking" , walk_mode_keyboard_and_mouse)
	_build_section(_keyboard_and_mouse_container, "Building", build_mode_keyboard_and_mouse)
	_build_section(_controller_container, "Walking", walk_mode_controller)
	_build_section(_controller_container, "Building", build_mode_controller)


func _clear(container:Container):
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	

func _build_section(container:Container, title:String, mapping_context:GUIDEMappingContext):
		
	var input_section:InputSection = InputSectionScene.instantiate()
	input_section.title = title
	container.add_child(input_section)
		
	var items:Array[GUIDERemapper.ConfigItem] = _remapper.get_remappable_items(mapping_context)
	for item in items:
		var input_binding:InputBinding = InputBindingScene.instantiate()
		input_binding.title = item.display_name
		var input:GUIDEInput = _remapper.get_bound_input_or_null(item)
		_update_bound_input(input, input_binding)
		item.changed.connect(_update_bound_input.bind(input_binding))
		
		input_binding.binding_change_requested.connect(_on_binding_change_requested.bind(item))
		container.add_child(input_binding)
		
		print(item.display_name)
		
func _update_bound_input(input:GUIDEInput, input_binding:InputBinding):
	input_binding.bound_input = await _guide_input_formatter.input_as_richtext_async(input)		


func _on_binding_change_requested(item:GUIDERemapper.ConfigItem):
	_input_prompt.visible = true
	
	var devices:Array[GUIDEInputDetector.DeviceType] = []
	if item.context == build_mode_keyboard_and_mouse or \
			item.context == walk_mode_keyboard_and_mouse:
		devices = [GUIDEInputDetector.DeviceType.KEYBOARD, GUIDEInputDetector.DeviceType.MOUSE]
	else:
		devices = [GUIDEInputDetector.DeviceType.JOY]
	
	_input_detector.detect(item.value_type, devices)

	var detected_input:GUIDEInput = await _input_detector.input_detected
	_input_prompt.visible = false
	
	if detected_input == null:
		return
	
	var collisions:Array[GUIDERemapper.ConfigItem] = _remapper.get_input_collisions(item, detected_input)
	for collision:GUIDERemapper.ConfigItem in collisions:
		if collision.context == global_keyboard_and_mouse or \
			collision.context == global_controller:
			return
		
		if item.context != collision.context:
			continue
		if not collision.is_remappable:
			return	
		_remapper.set_bound_input(collision, null)
				
	print(detected_input)

	_remapper.set_bound_input(item, detected_input)




	








		
	
	
	
	
	
