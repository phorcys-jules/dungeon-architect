class_name ModLoader
extends RefCounted

var _registry: Dictionary = {}

func validate_mod_definition(definition: Dictionary) -> bool:
	if definition.is_empty():
		return false
	if not definition.has("id") or not definition.has("type") or not definition.has("data"):
		return false
	var mod_type := String(definition.get("type", ""))
	if mod_type != "trap" and mod_type != "monster":
		return false
	var data: Variant = definition.get("data")
	if typeof(data) != TYPE_DICTIONARY:
		return false
	var payload := data as Dictionary
	if mod_type == "trap":
		if not payload.has("name") or not payload.has("cost"):
			return false
		if not payload.has("damage") or not payload.has("cooldown"):
			return false
		if typeof(payload.name) != TYPE_STRING:
			return false
		return typeof(payload.cost) == TYPE_INT or typeof(payload.cost) == TYPE_FLOAT
	if not payload.has("name") or not payload.has("base_speed"):
		return false
	if not payload.has("hp") or not payload.has("attack"):
		return false
	if typeof(payload.name) != TYPE_STRING:
		return false
	return typeof(payload.base_speed) == TYPE_FLOAT or typeof(payload.base_speed) == TYPE_INT

func register_mod(mod: Dictionary) -> void:
	if mod.is_empty() or not mod.has("id"):
		return
	_registry[String(mod.id)] = mod

func get_registered_mod(id: String) -> Dictionary:
	return _registry.get(id, {})

func get_registered_mods() -> Dictionary:
	return _registry.duplicate(true)

func clear_registry() -> void:
	_registry.clear()

func load_mod(definition: Dictionary) -> Dictionary:
	if not validate_mod_definition(definition):
		return {}
	var normalized := {
		"id": String(definition.id),
		"type": String(definition.type),
		"data": Dictionary(definition.data).duplicate(true),
	}
	register_mod(normalized)
	return normalized

func load_mods_from_dir(path: String) -> Array[Dictionary]:
	var loaded: Array[Dictionary] = []
	var directory := DirAccess.open(path)
	if directory == null:
		return loaded
	directory.list_dir_begin()
	var filename := directory.get_next()
	while filename != "":
		if not directory.current_is_dir() and filename.ends_with(".json"):
			var file := FileAccess.open(path.path_join(filename), FileAccess.READ)
			if file != null:
				var parsed: Variant = JSON.parse_string(file.get_as_text())
				file.close()
				if typeof(parsed) == TYPE_DICTIONARY:
					var mod := load_mod(parsed as Dictionary)
					if not mod.is_empty():
						loaded.append(mod)
		filename = directory.get_next()
	directory.list_dir_end()
	return loaded
