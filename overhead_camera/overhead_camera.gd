class_name OverheadCamera
extends Node3D

@export var movement_speed:float = 20
@export var follow:Node3D
@export var active:bool:
	set(value):
		active = value
		_refresh()	

@export var move_camera:GUIDEAction

@onready var _camera_3d:Camera3D = %Camera3D
@onready var _offset:Node3D = %Offset

func _ready():
	_refresh()

func _process(delta):
	if not active:
		return
	
	_offset.position += _offset.basis * move_camera.value_axis_3d.normalized() * movement_speed * delta
	
	global_transform = follow.global_transform
	
	

	
func _refresh():
	if not is_instance_valid(_camera_3d):
		return
	
	_camera_3d.current = active
	_offset.position *= Vector3(0, 1, 0)
