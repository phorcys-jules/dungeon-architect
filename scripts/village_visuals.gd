class_name VillageVisuals
extends RefCounted

# Provides visual state and serialization for buildings based on level.
func get_visual_state(_building_name: String, level: int) -> String:
	if level <= 0:
		return "missing"
	if level == 1:
		return "basic"
	if level == 2:
		return "improved"
	return "legendary"

func serialize(building_name: String, level: int) -> Dictionary:
	return {
		"name": building_name,
		"level": level,
		"visual": get_visual_state(building_name, level),
	}

func restore(state: Dictionary) -> String:
	var building_name: String = String(state.get("name", "?"))
	var level: int = int(state.get("level", 0))
	return get_visual_state(building_name, level)
