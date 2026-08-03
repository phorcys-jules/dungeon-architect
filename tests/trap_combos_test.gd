extends SceneTree

const TrapCombos := preload("res://scripts/trap_combos.gd")

func _check(c,msg):
	if c: return true
	push_error("trap_combos test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var t := TrapCombos.new()
	var r := t.resolve_combo("poix","feu")
	if not _check(r.has("name"), "combo found"):
		return
	if not _check(r.effects.size() >= 1, "has effects"):
		return
	print("Trap combos test passed")
	quit(0)
