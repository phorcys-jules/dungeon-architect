extends SceneTree

const DailyChallenge := preload("res://scripts/daily_challenge.gd")

func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("daily challenge test failed: %s" % message)
	quit(1)
	return false

func _init() -> void:
	var daily_challenge := DailyChallenge.new()
	var config: Dictionary = daily_challenge.config_for_date("2026-08-03")
	if not _check(int(config.get("seed", 0)) != 0, "seed non-zero"):
		return
	if not _check(String(config.get("date", "")) == "2026-08-03", "date preserved"):
		return
	print("Daily challenge test passed")
	quit(0)
