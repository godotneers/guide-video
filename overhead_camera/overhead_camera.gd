extends Node3D
@export var move_camera:GUIDEAction

@export var movement_speed:float = 20
@export var follow:Node3D
@export var current:bool:
	set(value):
		current = value
		_refresh()	


@onready var _camera_3d:Camera3D = %Camera3D
@onready var _offset:Node3D = %Offset

func _ready():
	_refresh()

func _process(delta):
	if not current:
		return
	
	global_transform = follow.global_transform
	
	_offset.position += move_camera.value_axis_3d.normalized() * movement_speed * delta
	
func _refresh():
	if not is_instance_valid(_camera_3d):
		return
	
	_camera_3d.current = current
	_offset.position *= Vector3(0, 1, 0)
