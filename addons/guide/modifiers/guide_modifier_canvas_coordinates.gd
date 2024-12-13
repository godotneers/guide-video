## Converts a position input in viewport coordinates (e.g. from the mouse position input)
## into canvas coordinates (e.g. 2D world coordinates). Useful to get a 2D 'world' position.
@tool
class_name GUIDEModifierCanvasCoordinates
extends GUIDEModifier


func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	var viewport = Engine.get_main_loop().root
	var transform = viewport.canvas_transform.affine_inverse()
	var coordinates = transform * Vector2(input.x, input.y) 
	return Vector3(coordinates.x, coordinates.y, input.z)


func _editor_name() -> String:
	return "Canvas coordinates"


func _editor_description() -> String:
	return "Converts a position input in viewport coordinates (e.g. from the mouse position input)\n" + \
		"into canvas coordinates (e.g. 2D world coordinates). Useful to get a 2D 'world' position."
