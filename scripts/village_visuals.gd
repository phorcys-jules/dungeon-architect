class_name VillageVisuals
extends RefCounted

# Provides simple visual state for buildings based on level
func get_visual_state(building_name: String, level: int) -> String:
	if level <= 0:
		return "missing"
	elif level == 1:
		return "basic"
	elif level == 2:
		return "improved"
	else:
		return "legendary"
