extends SceneTree

const SuspicionSystem := preload("res://scripts/suspicion_system.gd")

func _check(c,msg):
	if c: return true
	push_error("suspicion test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var s := SuspicionSystem.new()
	var naive := {"intelligence":0.2}
	if not _check(is_equal_approx(s.compute_suspicion(naive, []).to_float(),0.2), "naive base"):
		return
	if not _check(s.compute_suspicion(naive, [1,2,3]) > 0.2, "observations increase"):
		return
	print("Suspicion test passed")
	quit(0)
