extends SceneTree

const DebriefManager := preload("res://scripts/debrief_manager.gd")

func _check(c,msg):
	if c: return true
	push_error("debrief test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var d := DebriefManager.new()
	var replay := {"positions": [{"pos": Vector2(0,0), "time": 0.0}, {"pos": Vector2(1,0), "time": 1.0}], "events": [{"type":"damage","time":1.0,"data":{"amount":5}}]}
	var r := d.analyze(replay)
	if not _check(r.summary.samples == 2, "samples count"):
		return
	if not _check(r.summary.events_count == 1, "events count"):
		return
	if not _check(r.heatmap.size() >= 1, "heatmap bins"):
		return
	print("Debrief manager test passed")
	quit(0)
