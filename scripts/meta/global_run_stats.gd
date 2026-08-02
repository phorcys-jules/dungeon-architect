class_name GlobalRunStats
extends RefCounted

var total_runs := 0
var victories := 0
var total_score := 0
var best_score := 0
var best_wave := 0
var total_captures := 0
var total_resources := {"gold": 0, "essence": 0, "stone": 0, "bones": 0}
var favorite_monsters: Dictionary = {}
var favorite_synergies: Dictionary = {}

func record_run(result: Dictionary) -> void:
    total_runs += 1
    if bool(result.get("victory", false)):
        victories += 1
    var score := int(result.get("score", 0))
    total_score += score
    best_score = maxi(best_score, score)
    best_wave = maxi(best_wave, int(result.get("wave", 0)))
    total_captures += int(result.get("captures", 0))
    var resources: Dictionary = result.get("resources", {})
    for key in total_resources.keys():
        total_resources[key] = int(total_resources[key]) + int(resources.get(key, 0))
    for monster_id in result.get("monster_ids", []):
        var id := String(monster_id)
        favorite_monsters[id] = int(favorite_monsters.get(id, 0)) + 1
    for synergy_id in result.get("synergy_ids", []):
        var id := String(synergy_id)
        favorite_synergies[id] = int(favorite_synergies.get(id, 0)) + 1

func win_rate() -> float:
    return 0.0 if total_runs == 0 else float(victories) / float(total_runs)

func average_score() -> float:
    return 0.0 if total_runs == 0 else float(total_score) / float(total_runs)

func most_used(source: Dictionary) -> String:
    var best_id := ""
    var best_count := -1
    for id in source:
        var count := int(source[id])
        if count > best_count or (count == best_count and String(id) < best_id):
            best_id = String(id)
            best_count = count
    return best_id

func to_dict() -> Dictionary:
    return {
        "total_runs": total_runs,
        "victories": victories,
        "total_score": total_score,
        "best_score": best_score,
        "best_wave": best_wave,
        "total_captures": total_captures,
        "total_resources": total_resources.duplicate(true),
        "favorite_monsters": favorite_monsters.duplicate(true),
        "favorite_synergies": favorite_synergies.duplicate(true),
    }

func from_dict(data: Dictionary) -> void:
    total_runs = int(data.get("total_runs", 0))
    victories = int(data.get("victories", 0))
    total_score = int(data.get("total_score", 0))
    best_score = int(data.get("best_score", 0))
    best_wave = int(data.get("best_wave", 0))
    total_captures = int(data.get("total_captures", 0))
    total_resources = data.get("total_resources", total_resources).duplicate(true)
    favorite_monsters = data.get("favorite_monsters", {}).duplicate(true)
    favorite_synergies = data.get("favorite_synergies", {}).duplicate(true)
