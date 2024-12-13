extends Node3D

@onready var _third_person_camera:ThirdPersonCamera = %ThirdPersonCamera
@onready var _overhead_camera:OverheadCamera = %OverheadCamera
@onready var _build_mode_ui:BuildModeUI = %BuildMode
@onready var _navigation_region_3d:NavigationRegion3D = %NavigationRegion3D

@export var walk_mode:GUIDEMappingContext
@export var build_mode:GUIDEMappingContext

@export var switch_to_build_mode:GUIDEAction
@export var switch_to_walk_mode:GUIDEAction 

func _ready():
	switch_to_build_mode.triggered.connect(_switch_to_build_mode)
	switch_to_walk_mode.triggered.connect(_switch_to_walk_mode)
	_switch_to_walk_mode()
	

func _switch_to_build_mode():
	GUIDE.disable_mapping_context(walk_mode)	
	GUIDE.enable_mapping_context(build_mode)
	
	_overhead_camera.active = true
	_third_person_camera.active = false
	_build_mode_ui.active = true
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	
func _switch_to_walk_mode():
	GUIDE.disable_mapping_context(build_mode)	
	GUIDE.enable_mapping_context(walk_mode)
	
	_overhead_camera.active = false
	_third_person_camera.active = true
	_build_mode_ui.active = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	


func _on_build_mode_building_built():
	_navigation_region_3d.bake_navigation_mesh(true)

