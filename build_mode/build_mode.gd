extends CanvasLayer

signal building_built()

@export var cursor_3d:GUIDEAction
@export var cursor_2d:GUIDEAction

@export var place_building:GUIDEAction
@export var abort_placement:GUIDEAction
@export var tower_scene:PackedScene

@onready var _blocked_label:Control = %BlockedLabel
@onready var _cursor_position:Node3D = %CursorPosition
var _current_tower:Tower = null


var active:bool = false:
	set(value):
		active = value
		visible = active
		if not active and is_instance_valid(_current_tower):
			_current_tower.queue_free()
			_current_tower = null


func _ready():
	place_building.triggered.connect(_on_place_building)
	abort_placement.triggered.connect(_on_abort_placement)


func _process(delta):
	if not active:
		return
	
	if is_instance_valid(_current_tower):
		_blocked_label.visible = not _current_tower.is_location_clear()
		if _blocked_label.visible:
			_blocked_label.global_position = cursor_2d.value_axis_2d
	else:
		_blocked_label.visible = false
		
	_cursor_position.global_position = cursor_3d.value_axis_3d


func _on_place_building():
	if not is_instance_valid(_current_tower):
		return
		
	if not _current_tower.is_location_clear():
		return
		
	_current_tower.placement_mode = false
	_current_tower.reparent(get_parent())
	_current_tower = null
	building_built.emit()


func _on_abort_placement():
	if not is_instance_valid(_current_tower):
		return
		
	_current_tower.queue_free()
	_current_tower = null

func _on_place_tower_button_pressed():
	if is_instance_valid(_current_tower):
		return
	
	_current_tower = tower_scene.instantiate()
	_cursor_position.add_child(_current_tower)
	_current_tower.placement_mode = true
	pass # Replace with function body.
