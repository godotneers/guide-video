extends Node3D


@export var to_spawn:PackedScene
@export var interval:float = 0.5
@export var radius:float = 20

var _elapsed:float = 0

func _process(delta:float):
	_elapsed += delta
	if _elapsed > interval:
		_elapsed -= interval
		
		var angle := randf() * TAU
		var pos := to_global(Vector3(cos(angle) * radius, 0, sin(angle) * radius))
		
		var item:Node3D = to_spawn.instantiate()
		get_parent().add_child(item)
		item.global_position = pos
		
		
		
