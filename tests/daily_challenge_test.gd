extends SceneTree

const DailyChallengeScript := preload("res://scripts/daily_challenge.gd")


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("daily challenge test failed: %s" % message)
	quit(1)
	return false


func _init() -> void:
	var cfg: Dictionary = DailyChallengeScript.make_daily_config_from_date("2026-08-03")
	if not _check(int(cfg.get("seed", 0)) != 0, "seed non-zero"):
		return
	if not _check(String(cfg.get("date", "")) == "2026-08-03", "date preserved"):
		return
	if not _check(cfg.has("rules"), "rules generated"):
		return
	print("Daily challenge test passed")
	quit(0)
