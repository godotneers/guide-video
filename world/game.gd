extends Node3D

@onready var _third_person_camera = %ThirdPersonCamera
@onready var _overhead_camera = %OverheadCamera
@onready var _build_mode = %BuildMode
@onready var _navigation_region_3d:NavigationRegion3D = %NavigationRegion3D

func _ready():
	_switch_to_walk_mode()


func _switch_to_walk_mode():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# TODO: set up input, activate player walking

	_overhead_camera.current = false
	_third_person_camera.current = true
	_build_mode.active = false
	
	
func _switch_to_build_mode():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# TODO: set up input, prevent player from walking

	_third_person_camera.current = false
	_overhead_camera.current = true
	_build_mode.active = true
	

func _on_build_mode_building_built():
	_navigation_region_3d.bake_navigation_mesh(true)

