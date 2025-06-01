extends Node

@export var walk_mode_keyboard_and_mouse:GUIDEMappingContext
@export var build_mode_keyboard_and_mouse:GUIDEMappingContext
@export var global_keyboard_and_mouse:GUIDEMappingContext

@export var walk_mode_controller:GUIDEMappingContext
@export var build_mode_controller:GUIDEMappingContext
@export var global_controller:GUIDEMappingContext

@export var switch_to_walk_mode:GUIDEAction
@export var switch_to_build_mode:GUIDEAction

@export var switch_to_controller:GUIDEAction
@export var switch_to_keyboard_and_mouse:GUIDEAction

@export var toggle_settings_dialog:GUIDEAction

var _in_settings:bool = false

enum GameMode {
	BUILD_MODE,
	WALK_MODE
}
var _game_mode:GameMode = GameMode.WALK_MODE

enum InputMode {
	KEYBOARD_AND_MOUSE,
	CONTROLLER
}
var _input_mode:InputMode = InputMode.KEYBOARD_AND_MOUSE

func _ready():
	switch_to_build_mode.triggered.connect(_set_game_mode.bind(GameMode.BUILD_MODE))
	switch_to_walk_mode.triggered.connect(_set_game_mode.bind(GameMode.WALK_MODE))
	
	switch_to_controller.triggered.connect(_set_input_mode.bind(InputMode.CONTROLLER))
	switch_to_keyboard_and_mouse.triggered.connect(_set_input_mode.bind(InputMode.KEYBOARD_AND_MOUSE))
	
	toggle_settings_dialog.triggered.connect(_toggle_settings)
	GUIDE.set_remapping_config(RemappingConfiguration.get_current())
	_update_input()
	
func _toggle_settings():
	_in_settings = not _in_settings
	_update_input()	
	
func _set_game_mode(mode:GameMode):
	_game_mode = mode
	_update_input()
	
	
func _set_input_mode(mode:InputMode):
	_input_mode = mode
	_update_input()


func _update_input():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	match _input_mode:
		InputMode.KEYBOARD_AND_MOUSE:
			GUIDE.enable_mapping_context(global_keyboard_and_mouse, true)

			if _in_settings:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				return
								
			match _game_mode:
				GameMode.BUILD_MODE:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					GUIDE.enable_mapping_context(build_mode_keyboard_and_mouse)
				GameMode.WALK_MODE:
					GUIDE.enable_mapping_context(walk_mode_keyboard_and_mouse)
		
		InputMode.CONTROLLER:
			GUIDE.enable_mapping_context(global_controller, true)
			
			if _in_settings:
				return 
				
			match _game_mode:
				GameMode.BUILD_MODE:
					GUIDE.enable_mapping_context(build_mode_controller)
				GameMode.WALK_MODE:
					GUIDE.enable_mapping_context(walk_mode_controller)
	
				
