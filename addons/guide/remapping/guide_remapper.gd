class_name GUIDERemapper

## Emitted when the bound input of an item changes. 
signal item_changed(item:ConfigItem, input:GUIDEInput)

var _remapping_config:GUIDERemappingConfig = GUIDERemappingConfig.new()
var _mapping_contexts:Array[GUIDEMappingContext] = []

const GUIDESet = preload("../guide_set.gd")

## Loads the default bindings as they are currently configured in the mapping contexts and a mapping
## config for editing. Note that the given mapping config will not be modified, so editing can be
## cancelled. Call get_mapping_config to get the modified mapping config.
func initialize(mapping_contexts:Array[GUIDEMappingContext], remapping_config:GUIDERemappingConfig):
	_remapping_config = remapping_config.duplicate() if remapping_config != null else GUIDERemappingConfig.new()
	
	_mapping_contexts.clear()
	
	for mapping_context in mapping_contexts:
		if not is_instance_valid(mapping_context):
			push_error("Cannot add null mapping context. Ignoring.")
			return
		_mapping_contexts.append(mapping_context)
			
			
## Returns the mapping config with all modifications applied.
func get_mapping_config() -> GUIDERemappingConfig:
	return _remapping_config.duplicate()
	
	
func set_custom_data(key:Variant, value:Variant):
	_remapping_config.custom_data[key] = value
	
	
func get_custom_data(key:Variant, default:Variant = null) -> Variant:
	return _remapping_config.custom_data.get(key, default)	
	
	
func remove_custom_data(key:Variant) -> void:
	_remapping_config.custom_data.erase(key)
	
	
## Returns all remappable items. Can be filtered by context and display category.
func get_remappable_items(context:GUIDEMappingContext = null, display_category:String = "") -> Array[ConfigItem]:
	var result:Array[ConfigItem] = []
	for a_context:GUIDEMappingContext in _mapping_contexts:
		if context != null and context != a_context:
			continue
		for action_mapping:GUIDEActionMapping in a_context.mappings:
			var action:GUIDEAction = action_mapping.action
			if not action.is_remappable:
				continue
			
			if display_category.length() > 0 and action.display_category != display_category:
				continue
			
			for index:int in action_mapping.input_mappings.size():
				var item = ConfigItem.new(a_context, action_mapping.action, index)
				item_changed.connect(item._item_changed)
				result.append(item)
		
	return result

## Returns a list of all collisions in all contexts when this new input would be applied to the config item.
func get_input_collisions(item:ConfigItem, input:GUIDEInput) -> Array[ConfigItem]:
	if not _check_item(item):
		return []
	var result:Array[ConfigItem] = [] 
	
	if input == null:
		# no item collides with absent input
		return result
	
	# walk over all known contexts and find any mappings.
	for context:GUIDEMappingContext in _mapping_contexts:
		for action_mapping:GUIDEActionMapping in context.mappings:
			for index:int in action_mapping.input_mappings.size():
				var action := action_mapping.action
				if context == item.context and action == item.action and index == item.index:
					# collisions with self are allowed
					continue

				var bound_input:GUIDEInput = action_mapping.input_mappings[index].input
				# check if this is currently overridden
				if _remapping_config._has(context, action, index):
					bound_input = _remapping_config._get_bound_input_or_null(context, action, index)
					
				# We have a collision	
				if bound_input != null and bound_input.is_same_as(input):	
					var collision_item := ConfigItem.new(context, action, index)
					item_changed.connect(collision_item._item_changed)
					result.append(collision_item)

	return result


## Gets the input currently bound to the action in the given context. Can be null if the input
## is currently not bound.
func get_bound_input_or_null(item:ConfigItem) -> GUIDEInput:
	if not _check_item(item):
		return null

	# If the remapping config has a binding for this, this binding wins.
	if _remapping_config._has(item.context, item.action, item.index):
		return _remapping_config._get_bound_input_or_null(item.context, item.action, item.index)
		
	# otherwise return the default binding for this action in the context
	for action_mapping:GUIDEActionMapping in item.context.mappings:
		if action_mapping.action == item.action:
			if action_mapping.input_mappings.size() > item.index:
				return action_mapping.input_mappings[item.index].input
			else:
				push_error("Action mapping does not have an index of ", item.index , ".")
				
	return null
	
## Sets the bound input to the new value for the given config item. Ignores collisions
## because collision resolution is highly game specific. Use get_input_collisions to find
## potential collisions and then resolve them in a way that suits the game. Note that 
## bound input can be set to null, which deliberately unbinds the input. If you want
## to restore the defaults, call restore_default instead.
func set_bound_input(item:ConfigItem, input:GUIDEInput) -> void:
	if not _check_item(item):
		return
		
	# first remove any custom binding we have 
	_remapping_config._clear(item.context, item.action, item.index)
	
	# Now check if the input is the same as the default
	var bound_input:GUIDEInput = get_bound_input_or_null(item)
	
	if bound_input == null and input == null:
		item_changed.emit(item, input)
		return # nothing to do
	
	if bound_input == null:
		_remapping_config._bind(item.context, item.action, input, item.index)
		item_changed.emit(item, input)
		return
		
	if bound_input != null and input != null and bound_input.is_same_as(input):
		item_changed.emit(item, input)
		return # nothing to do	
		
	_remapping_config._bind(item.context, item.action, input, item.index)
	item_changed.emit(item, input)
		
		
## Returns the default binding for the given config item.
func get_default_input(item:ConfigItem) -> GUIDEInput:
	if not _check_item(item):
		return null
		
	for mapping:GUIDEActionMapping in item.context.mappings:
		if mapping.action == item.action:
			# _check_item verifies the index exists, so no need to check here.
			return mapping.input_mappings[item.index].input
				
	return null
	

## Restores the default binding for the given config item. Note that this may
## introduce a conflict if other bindings have bound conflicting input. You can
## call get_default_input for the given item to get the default input and then
## call get_input_collisions for that to find out whether you would get a collision.
func restore_default_for(item:ConfigItem) -> void:
	if not _check_item(item):
		return

	_remapping_config._clear(item.context, item.action, item.index)
	item_changed.emit(item, get_bound_input_or_null(item))


		
## Verifies that the given item is valid.
func _check_item(item:ConfigItem) -> bool:
	if not _mapping_contexts.has(item.context):
		push_error("Given context is not known to this mapper. Did you call initialize()?")
		return false
	
	var action_found := false
	var size_ok := false
	for mapping in item.context.mappings:
		if mapping.action == item.action:
			action_found = true
			if mapping.input_mappings.size() > item.index and item.index >= 0:
				size_ok = true
			break
			
	if not action_found:
		push_error("Given action does not belong to the given context.")
		return false
		
	if not size_ok:
		push_error("Given index does not exist for the given action's input binding.")


	if not item.action.is_remappable:
		push_error("Given action is not remappable.")
		return false
		
	return true
	

class ConfigItem:
	## Emitted when the input to this item has changed.
	signal changed(input:GUIDEInput)
	
	var context:GUIDEMappingContext	
	var action:GUIDEAction
	var index:int
	
	func _init(context:GUIDEMappingContext, action:GUIDEAction, index:int):
		self.context = context
		self.action = action
		self.index = index
		
	func is_same_as(other:ConfigItem) -> bool:
		return context == other.context and \
				action == other.action and \
				index == other.index
			
	func _item_changed(item:ConfigItem, input:GUIDEInput):
		if item.is_same_as(self):
			changed.emit(input)
		
