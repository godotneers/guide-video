class_name BuildModeUI
extends CanvasLayer

signal building_built()

@export var tower_scene:PackedScene
@export var select_tower:GUIDEAction
@export var place_tower:GUIDEAction
@export var cancel_tower_placement:GUIDEAction
@export var tower_position:GUIDEAction
@export var tower_position_2d:GUIDEAction

@onready var _blocked_label:Control = %BlockedLabel

var _current_tower:Tower

func _ready():
	select_tower.triggered.connect(_select_tower)
	place_tower.triggered.connect(_place_tower)
	cancel_tower_placement.triggered.connect(_cancel_tower_placement)

var active:bool = false:
	set(value):
		active = value
		visible = active


func _process(delta):
	if not active:
		return

	if _current_tower != null:
		_current_tower.global_position = tower_position.value_axis_3d
		_blocked_label.visible = not _current_tower.is_location_clear()
		_blocked_label.global_position = tower_position_2d.value_axis_2d

func _place_tower():
	if _current_tower != null and _current_tower.is_location_clear():
		_current_tower.placement_mode = false
		_current_tower = null
		building_built.emit()
		
func _cancel_tower_placement():
	if _current_tower != null:
		_current_tower.queue_free()
		_current_tower = null
		_blocked_label.visible = false


func _select_tower():
	if _current_tower != null:
		return
		
	_current_tower = tower_scene.instantiate()
	get_parent().add_child(_current_tower)
	_current_tower.placement_mode = true
	
	pass		


