class_name ThirdPersonCamera
extends Node3D

@export var follow:Node3D
@export var active:bool:
	set(value):
		active = value
		_refresh()	
@export var rotate_camera:GUIDEAction		

@onready var _pitch:Node3D = %Pitch
@onready var _camera_3d = %Camera3D

func _ready():
	_refresh()


func _process(delta):
	_pitch.rotation_degrees.x = clamp(_pitch.rotation_degrees.x + rotate_camera.value_axis_1d, -90, 0)
	
	# follow movements of the player
	if is_instance_valid(follow):
		transform = follow.transform



func _refresh():
	if not is_instance_valid(_camera_3d):
		return
		
	_camera_3d.current = active
