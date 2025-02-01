extends Node3D

@export var switch_to_build_mode:GUIDEAction
@export var switch_to_walk_mode:GUIDEAction

@onready var _third_person_camera:ThirdPersonCamera = %ThirdPersonCamera
@onready var _overhead_camera:OverheadCamera = %OverheadCamera
@onready var _build_mode_ui:BuildModeUI = %BuildMode
@onready var _navigation_region_3d:NavigationRegion3D = %NavigationRegion3D

func _ready():
	switch_to_build_mode.triggered.connect(_switch_to_build_mode)
	switch_to_walk_mode.triggered.connect(_switch_to_walk_mode)
	
	_switch_to_walk_mode()
	
func _switch_to_build_mode():
	_overhead_camera.active = true
	_third_person_camera.active = false
	_build_mode_ui.active = true
	
	
func _switch_to_walk_mode():
	_overhead_camera.active = false
	_third_person_camera.active = true
	_build_mode_ui.active = false
	
	

func _on_build_mode_building_built():
	_navigation_region_3d.bake_navigation_mesh(true)
