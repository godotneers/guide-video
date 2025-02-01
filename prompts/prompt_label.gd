extends RichTextLabel

@export_multiline var prompt:String = ""
@export var actions:Array[GUIDEAction] = []
@export var show_in_contexts:Array[GUIDEMappingContext] = []


var _formatter:GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts(48)

func _ready():
	GUIDE.input_mappings_changed.connect(_update_label)
	_update_label()
	
func _update_label():
	if not show_in_contexts.is_empty():
		if not show_in_contexts.any(func(it): return GUIDE.is_mapping_context_enabled(it)):
			visible = false
			return
	
	visible = true
	
	var actions_as_richtext:Array[String] = []
	actions_as_richtext.resize(actions.size())
	
	for i in actions.size():
		actions_as_richtext[i] = await _formatter.action_as_richtext_async(actions[i])
		
	text = prompt % actions_as_richtext
