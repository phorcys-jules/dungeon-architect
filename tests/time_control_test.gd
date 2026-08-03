extends SceneTree

const TimeControl := preload("res://scripts/time_control.gd")

func _check(c,msg):
	if c: return true
	push_error("time_control test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var t := TimeControl.new()
	if not _check(is_equal_approx(t.get_multiplier(),1.0),"default normal"):
		return
	t.set_mode(TimeControl.Mode.X2)
	if not _check(is_equal_approx(t.get_multiplier(),2.0),"x2"):
		return
	t.set_mode(TimeControl.Mode.PAUSED)
	if not _check(is_equal_approx(t.get_multiplier(),0.0),"paused"):
		return
	print("TimeControl test passed")
	quit(0)
