extends SceneTree

const BiomeMechanics := preload("res://scripts/biome_mechanics.gd")

func _check(c,msg):
	if c: return true
	push_error("biome_mechanics test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var b := BiomeMechanics.new()
	if not _check(b.get_mechanics("crypt").size() >= 2, "crypt mechanics"):
		return
	if not _check(b.get_mechanics("unknown").size() == 0, "unknown empty"):
		return
	print("Biome mechanics test passed")
	quit(0)
