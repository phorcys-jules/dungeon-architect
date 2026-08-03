extends SceneTree

const DestructibleArchitecture := preload("res://scripts/destructible_architecture.gd")

func _check(c,msg):
	if c: return true
	push_error("destructible test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var d := DestructibleArchitecture.new()
	if not _check(d.get_state_from_hp(0,100) == "destroyed", "0hp destroyed"):
		return
	if not _check(d.get_state_from_hp(20,100) == "critical", "20% critical"):
		return
	if not _check(d.get_state_from_hp(90,100) == "intact", "90% intact"):
		return
	print("Destructible architecture test passed")
	quit(0)
