extends SceneTree

const VillageVisuals := preload("res://scripts/village_visuals.gd")

func _check(cond: bool, msg: String) -> bool:
	if cond:
		return true
	push_error("village_visuals test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var v := VillageVisuals.new()
	if not _check(v.get_visual_state("Inn", 0) == "missing", "level 0 must be missing"):
		return
	if not _check(v.get_visual_state("Inn", 1) == "basic", "level1 basic"):
		return
	if not _check(v.get_visual_state("Inn", 3) == "legendary", "level3 legendary"):
		return
	print("Village visuals test passed")
	quit(0)
