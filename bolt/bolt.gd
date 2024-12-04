extends Node3D

@export var speed:float = 10
@export var lifetime:float = 2.0

func _process(delta: float) -> void:
	position += -basis.z * delta * speed
	lifetime -= delta
	if lifetime <= 0:
		queue_free()



# Collided with terrain/buildings
func _on_area_3d_body_entered(body):
	queue_free()


func _on_area_3d_area_entered(area):
	if area.owner.has_method("take_damage"):
		area.owner.take_damage()
		queue_free()
