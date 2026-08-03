class_name ModLoader
extends RefCounted

# Minimal mod validation: mod is a Dictionary with keys: id, type (trap|monster), data
func validate_mod_definition(defn: Dictionary) -> bool:
	if not defn.has("id") or not defn.has("type") or not defn.has("data"):
		return false
	var t := defn.get("type")	
	if t != "trap" and t != "monster":
		return false
	return true

func load_mod(defn: Dictionary) -> Dictionary:
	if not validate_mod_definition(defn):
		return {}
	# return normalized definition
	return {"id":str(defn.id), "type":str(defn.type), "data":defn.data}

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
