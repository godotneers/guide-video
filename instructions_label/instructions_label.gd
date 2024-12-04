extends RichTextLabel

@export_multiline var instructions_text:String
@export var actions:Array[GUIDEAction] = []
@export var icon_size:int = 32
@export var limit_to_context:GUIDEMappingContext

var _formatter:GUIDEInputFormatter

func _ready():
	GUIDE.input_mappings_changed.connect(_update_instructions)
	_formatter = GUIDEInputFormatter.for_active_contexts(icon_size)
	
	
func _update_instructions():
	if limit_to_context != null and not GUIDE.is_mapping_context_enabled(limit_to_context):
		visible = false
		return
	
	visible = true
	
	# Update the prompts.
	var replacements:Array[String] = []
	for action in actions:
		replacements.append(await _formatter.action_as_richtext_async(action))
	
	parse_bbcode(instructions_text % replacements)
