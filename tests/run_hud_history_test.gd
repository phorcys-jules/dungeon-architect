extends SceneTree

func _init() -> void:
    var hud := RunHudViewModel.new().build({
        "current_health": 45.0,
        "max_health": 90.0,
        "wave": 4,
        "total_waves": 7,
        "difficulty": "Difficile",
        "treasure_state": "stolen",
        "active_synergies": ["Brume spectrale", "Gel visqueux"],
        "status_effects": ["ralenti"],
        "gold": 120,
        "essence": 14,
    })
    if not is_equal_approx(float(hud.health_ratio), 0.5):
        quit(1)
        return
    if String(hud.wave_text) != "Vague 4 / 7" or String(hud.treasure_text) != "Trésor : volé":
        quit(1)
        return

    var records := [
        {"victory": true, "difficulty": "Normal", "waves_completed": 6, "score": 950, "duration_seconds": 615.0, "treasure_safe": true, "gold_reward": 80, "essence_reward": 9},
        {"victory": false, "difficulty": "Difficile", "waves_completed": 3, "score": 420, "duration_seconds": 302.0, "treasure_safe": false, "gold_reward": 35, "essence_reward": 3},
    ]
    var history := RunHistoryViewModel.new()
    var rows := history.build_rows(records)
    var summary := history.summary(records)
    if rows.size() != 2 or String(rows[0].duration) != "10:15":
        quit(1)
        return
    if int(summary.runs) != 2 or int(summary.wins) != 1 or int(summary.best_score) != 950:
        quit(1)
        return
    if not is_equal_approx(float(summary.win_rate), 0.5):
        quit(1)
        return
    print("Run HUD and history test passed")
    quit(0)
