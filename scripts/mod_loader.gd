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
	# In real loader, register definitions; here return normalized definition
	return {"id":str(defn.id), "type":str(defn.type), "data":defn.data}
