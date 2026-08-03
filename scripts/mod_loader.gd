class_name ModLoader
extends RefCounted

# Minimal mod validation: mod is a Dictionary with keys: id, type (trap|monster), data
func validate_mod_definition(defn: Dictionary) -> bool:
	if not defn or typeof(defn) != TYPE_DICTIONARY:
		return false
	if not defn.has("id") or not defn.has("type") or not defn.has("data"):
		return false
	var t := String(defn.get("type"))
	if t != "trap" and t != "monster":
		return false
	# type-specific required fields
	var d := defn.get("data")
	if typeof(d) != TYPE_DICTIONARY:
		return false
	if t == "trap":
		if not d.has("name") or not d.has("cost") or not d.has("damage") or not d.has("cooldown"):
			return false
		# basic type checks
		if typeof(d.name) != TYPE_STRING or typeof(d.cost) != TYPE_INT and typeof(d.cost) != TYPE_FLOAT:
			return false
		return true
	else:
		# monster
		if not d.has("name") or not d.has("base_speed") or not d.has("hp") or not d.has("attack"):
			return false
		if typeof(d.name) != TYPE_STRING:
			return false
		if typeof(d.base_speed) != TYPE_FLOAT and typeof(d.base_speed) != TYPE_INT:
			return false
		return true

# simple registry kept in-memory for the running session
var _registry := {}

func register_mod(mod: Dictionary) -> void:
	if not mod or not mod.has("id"):
		return
	_registry[str(mod.id)] = mod

func get_registered_mod(id: String) -> Dictionary:
	return _registry.get(id, {})

func get_registered_mods() -> Dictionary:
	return _registry

func clear_registry() -> void:
	_registry.clear()

func load_mod(defn: Dictionary) -> Dictionary:
	if not validate_mod_definition(defn):
		return {}
	var normalized = {"id":str(defn.id), "type":str(defn.type), "data":defn.data}
	register_mod(normalized)
	return normalized

func load_mods_from_dir(path: String) -> Array:
	var dir := DirAccess.open(path)
	var loaded := []
	if dir == null:
		return loaded
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if not dir.current_is_dir():
			if fname.ends_with('.json'):
				var fpath := path.plus_file(fname)
				var file := FileAccess.open(fpath, FileAccess.READ)
				if file:
					var txt := file.get_as_text()
					file.close()
					var ok, data = JSON.parse_string(txt)
					if ok == OK:
						var mod = load_mod(data)
						if mod.size() > 0:
							loaded.append(mod)
		fname = dir.get_next()
	dir.list_dir_end()
	return loaded
