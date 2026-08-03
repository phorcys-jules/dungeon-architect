extends SceneTree

const LocalizationChecker := preload("res://scripts/localization_checker.gd")

func _check(c,msg):
	if c: return true
	push_error("localization test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var lc := LocalizationChecker.new()
	var base := {"hello":"Bonjour","bye":"Au revoir"}
	var fr := {"hello":"Bonjour"}
	var miss := lc.missing_keys(base, fr)
	if not _check(miss.has("bye"), "missing bye detected"):
		return
	print("Localization checker test passed")
	quit(0)
