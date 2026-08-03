class_name VillageVisuals
extends RefCounted

# Provides visual state and serialization for buildings based on level
func get_visual_state(building_name: String, level: int) -> String:
	if level <= 0:
		return "missing"
	elif level == 1:
		return "basic"
	elif level == 2:
		return "improved"
	else:
		return "legendary"

func serialize(building_name: String, level: int) -> Dictionary:
	return {"name": building_name, "level": level, "visual": get_visual_state(building_name, level)}

func restore(state: Dictionary) -> String:
	# safe restore from save data
	var name := state.get("name", "?")
	var level := int(state.get("level", 0))
	return get_visual_state(name, level)
