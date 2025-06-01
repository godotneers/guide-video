class_name RemappingConfiguration

const SAVE_PATH = "user://remapping_config.tres"

static func get_current() -> GUIDERemappingConfig:
	if not ResourceLoader.exists(SAVE_PATH):
		return GUIDERemappingConfig.new()
		
	return ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	
	
static func save(new_config:GUIDERemappingConfig):
	ResourceSaver.save(new_config, SAVE_PATH)
