extends SceneTree

const DailyChallenge := preload("res://scripts/daily_challenge.gd")

func _check(c,msg):
	if c: return true
	push_error("daily challenge test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var dc := DailyChallenge.new()
	var cfg := dc.config_for_date("2026-08-03")
	if not _check(cfg.seed != 0, "seed non-zero"):
		return
	if not _check(cfg.date == "2026-08-03", "date preserved"):
		return
	print("Daily challenge test passed")
	quit(0)
