extends SceneTree

func _init() -> void:
    var cfg := DailyChallenge.make_daily_config_from_date("2026-08-03")
    if cfg.get("date") != "2026-08-03":
        push_error("date mismatch in daily config")
        quit(1)
        return
    if int(cfg.get("seed")) != 20260803:
        push_error("seed mismatch: expected 20260803 got %s" % str(cfg.get("seed")))
        quit(1)
        return
    print("Daily challenge GDScript test passed")
    quit(0)
