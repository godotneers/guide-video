extends Node3D


@export var build_mode:GUIDEMappingContext
@export var walk_mode:GUIDEMappingContext
@export var to_walk_mode:GUIDEAction
@export var to_build_mode:GUIDEAction

@onready var _third_person_camera = %ThirdPersonCamera
@onready var _overhead_camera = %OverheadCamera
@onready var _build_mode = %BuildMode
@onready var _navigation_region_3d:NavigationRegion3D = %NavigationRegion3D

func _ready():
	to_walk_mode.triggered.connect(_switch_to_walk_mode)
	to_build_mode.triggered.connect(_switch_to_build_mode)
	_switch_to_walk_mode()


func _switch_to_walk_mode():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GUIDE.disable_mapping_context(build_mode)
	GUIDE.enable_mapping_context(walk_mode)
	
	_overhead_camera.current = false
	_third_person_camera.current = true
	_build_mode.active = false
	
	
func _switch_to_build_mode():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GUIDE.disable_mapping_context(walk_mode)
	GUIDE.enable_mapping_context(build_mode)
	
	_third_person_camera.current = false
	_overhead_camera.current = true
	_build_mode.active = true
	

func _on_build_mode_building_built():
	_navigation_region_3d.bake_navigation_mesh(true)

