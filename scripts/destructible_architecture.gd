class_name DestructibleArchitecture
extends RefCounted

# Track structure HP states and allow damage/repair
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

func apply_damage(hp: int, damage: int) -> int:
	hp = max(0, hp - damage)
	return hp

func repair(hp: int, amount: int, max_hp: int) -> int:
	hp = min(max_hp, hp + amount)
	return hp

func needs_path_recalc(state: String) -> bool:
	# pathfinding should recalc on destroyed or critical
	return state == "destroyed" or state == "critical"
