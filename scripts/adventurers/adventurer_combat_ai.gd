class_name AdventurerCombatAi
extends RefCounted

static func profile(class_id: String) -> Dictionary:
    match class_id:
        "scout":
            return {"range_cells": 3.0, "damage": 15, "cooldown": 0.65, "strategy": &"wounded", "ranged": true}
        "champion":
            return {"range_cells": 1.35, "damage": 34, "cooldown": 1.15, "strategy": &"dangerous", "ranged": false}
        _:
            return {"range_cells": 1.65, "damage": 23, "cooldown": 0.85, "strategy": &"nearest", "ranged": false}

static func choose_target(candidates: Array[Dictionary], strategy: StringName) -> int:
    var best_index := -1
    var best_score := INF
    for candidate in candidates:
        if not bool(candidate.get("active", false)):
            continue
        var distance := float(candidate.get("distance", INF))
        var health_ratio := float(candidate.get("health_ratio", 1.0))
        var threat := float(candidate.get("threat", 0.0))
        var score := distance
        match strategy:
            &"wounded":
                score = health_ratio * 4.0 + distance
            &"dangerous":
                score = distance - threat * 0.12
        if score < best_score:
            best_score = score
            best_index = int(candidate.get("index", -1))
    return best_index
