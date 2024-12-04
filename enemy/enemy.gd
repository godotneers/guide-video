extends Node3D

@export var speed:float = 10

var _target:Node3D
var _delta:float
@onready var _agent = %NavigationAgent3D

func _ready():
	_prepare.call_deferred()
	
func _prepare():
	_target = get_tree().get_first_node_in_group("target")
	if _target == null:
		push_warning("No target")
		queue_free()
		
		
func take_damage():
	queue_free()

func _physics_process(delta):
	if _agent.is_navigation_finished() and _target != null:
		_agent.target_position = _target.global_position
		return
	
	var direction = global_position.direction_to(_agent.get_next_path_position())
	_agent.velocity = direction * speed
	
	_delta = delta
	
func _on_agent_velocity_computed(safe:Vector3):
	global_position += safe * _delta
	
	
func _on_area_3d_body_entered(body):
	queue_free()
