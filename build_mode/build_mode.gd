class_name BuildModeUI
extends CanvasLayer

signal building_built()

@export var tower_scene:PackedScene

@onready var _blocked_label:Control = %BlockedLabel


var active:bool = false:
	set(value):
		active = value
		visible = active


func _process(delta):
	if not active:
		return

		


