@tool
@icon("res://addons/guide/modifiers/guide_modifier.svg")
class_name GUIDEModifier
extends Resource


func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	return input

func _editor_name() -> String:
	return ""

func _editor_description() -> String:
	return ""
