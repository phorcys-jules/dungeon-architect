class_name DestructibleArchitecture
extends RefCounted

# Track structure HP states
func get_state_from_hp(hp: int, max_hp: int) -> String:
	var ratio := float(hp) / float(max_hp)
	if ratio <= 0.0:
		return "destroyed"
	elif ratio < 0.35:
		return "critical"
	elif ratio < 0.8:
		return "damaged"
	else:
		return "intact"
