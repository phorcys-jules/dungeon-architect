extends SceneTree

const SuspicionSystem := preload("res://scripts/suspicion_system.gd")

func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("suspicion test failed: %s" % message)
	quit(1)
	return false

func _init() -> void:
	var system := SuspicionSystem.new()
	var naive := {"intelligence": 0.2}
	var base_suspicion: float = float(system.compute_suspicion(naive, []))
	if not _check(is_equal_approx(base_suspicion, 0.2), "naive base"):
		return
	if not _check(float(system.compute_suspicion(naive, [1, 2, 3])) > 0.2, "observations increase"):
		return
	print("Suspicion test passed")
	quit(0)
