extends SceneTree

const AccessibilitySettings := preload("res://scripts/accessibility_settings.gd")

func _check(c,msg):
	if c: return true
	push_error("accessibility test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var a := AccessibilitySettings.new()
	a.set_colorblind("protanopia")
	if not _check(a.settings.colorblind_mode == "protanopia", "colorblind set"):
		return
	a.set_reduced_motion(true)
	if not _check(a.settings.reduced_motion == true, "reduced motion set"):
		return
	print("Accessibility settings test passed")
	quit(0)
