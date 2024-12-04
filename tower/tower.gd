class_name Tower
extends StaticBody3D

@export var cooldown:float = 0.2
@export var bolt_scene:PackedScene

@onready var _cannon:Node3D = %Cannon
@onready var _enemy_detector:Area3D = %EnemyDetector
@onready var _bolt_spawn_point:Node3D = %BoltSpawnPoint
@onready var _obstacle_detector:Area3D = %ObstacleDetector
@onready var _next_tower_detector:Area3D = %NextTowerDetector

@onready var _placement_aids:Node3D = %PlacementAids

var placement_mode:bool:
	set(value):
		placement_mode = value
		_placement_aids.visible = placement_mode
		

var _time_since_last_shot:float = 0

func _process(delta):
	if placement_mode:
		return
	
	if _time_since_last_shot < cooldown:
		_time_since_last_shot += delta
	
	var all_enemies:Array[Area3D] = _enemy_detector.get_overlapping_areas() 
	if all_enemies.is_empty():
		return

		
	var next_enemy = all_enemies[0]	
	_cannon.look_at(next_enemy.global_position * Vector3(1,0,1) + Vector3(0, _cannon.global_position.y, 0))
	
	if _time_since_last_shot > cooldown:
		var bolt:Node3D = bolt_scene.instantiate()
		get_parent().add_child(bolt)
		bolt.global_transform = _bolt_spawn_point.global_transform
		
		_time_since_last_shot -= cooldown
	
	
func is_location_clear() -> bool:
	if not placement_mode:
		return true
		
	var obstacles = _obstacle_detector.get_overlapping_bodies()
	if obstacles.any(func(it): return it != self):
		return false
		
	var nearby_towers = _next_tower_detector.get_overlapping_bodies()
	if nearby_towers.any(func(it): return it != self and it is Tower):
		return false
		
	return true	
		
		
	
	
