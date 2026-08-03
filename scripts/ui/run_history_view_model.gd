class_name RunHistoryViewModel
extends RefCounted

func build_rows(records: Array, limit: int = 10) -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    var count := mini(maxi(limit, 0), records.size())
    for index in range(count):
        var record: Dictionary = records[index]
        rows.append({
            "result": "Victoire" if bool(record.get("victory", false)) else "Défaite",
            "difficulty": String(record.get("difficulty", record.get("difficulty_id", "normal"))).capitalize(),
            "waves": maxi(int(record.get("waves_completed", 0)), 0),
            "score": maxi(int(record.get("score", record.get("damage_dealt", 0))), 0),
            "duration": _format_duration(maxf(float(record.get("duration_seconds", 0.0)), 0.0)),
            "treasure": "Sauvé" if bool(record.get("treasure_safe", record.get("treasure_protected", false))) else "Perdu",
            "rewards": "%d or · %d essence" % [maxi(int(record.get("gold_reward", 0)), 0), maxi(int(record.get("essence_reward", 0)), 0)],
        })
    return rows

func summary(records: Array) -> Dictionary:
    if records.is_empty():
        return {"runs": 0, "wins": 0, "best_score": 0, "win_rate": 0.0}
    var wins := 0
    var best_score := 0
    for record_variant in records:
        var record: Dictionary = record_variant
        if bool(record.get("victory", false)):
            wins += 1
        best_score = maxi(best_score, int(record.get("score", 0)))
    return {
        "runs": records.size(),
        "wins": wins,
        "best_score": best_score,
        "win_rate": float(wins) / float(records.size()),
    }

func _format_duration(seconds: float) -> String:
    var total := floori(seconds)
    return "%02d:%02d" % [total / 60, total % 60]
