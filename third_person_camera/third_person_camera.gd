extends Node3D

@export var tilt_camera:GUIDEAction
@export var follow:Node3D
@export var current:bool:
	set(value):
		current = value
		_refresh()	

@onready var _pitch:Node3D = %Pitch
@onready var _camera_3d = %Camera3D

func _ready():
	_refresh()


func _process(delta):
	# follow movements of the player
	if is_instance_valid(follow):
		transform = follow.transform
		
	# camera pitch
	_pitch.rotation.x = clamp(_pitch.rotation.x + tilt_camera.value_axis_1d, -PI/2.0, 0.0)


func _refresh():
	if not is_instance_valid(_camera_3d):
		return
		
	_camera_3d.current = current