class_name MonsterRoster
extends RefCounted

var capacity := 4
var recruited: Array[String] = ["ghost"]
var selected_team: Array[String] = ["ghost"]
var recruitment_costs := {
    "slime": 40,
    "mimic": 65,
    "spider": 55,
    "guardian": 80,
    "herder": 75,
}

func can_recruit(monster_id: String, available_gold: int) -> bool:
    return recruitment_costs.has(monster_id) and not recruited.has(monster_id) and available_gold >= int(recruitment_costs[monster_id])

func recruit(monster_id: String, available_gold: int) -> Dictionary:
    if not can_recruit(monster_id, available_gold):
        return {"ok": false, "gold_delta": 0}
    recruited.append(monster_id)
    return {"ok": true, "gold_delta": -int(recruitment_costs[monster_id])}

func select_team(monster_ids: Array[String]) -> bool:
    if monster_ids.is_empty() or monster_ids.size() > capacity:
        return false
    var unique: Array[String] = []
    for monster_id in monster_ids:
        if not recruited.has(monster_id) or unique.has(monster_id):
            return false
        unique.append(monster_id)
    selected_team = unique
    return true

func to_dict() -> Dictionary:
    return {
        "capacity": capacity,
        "recruited": recruited.duplicate(),
        "selected_team": selected_team.duplicate(),
    }

func from_dict(data: Dictionary) -> void:
    capacity = maxi(int(data.get("capacity", 4)), 1)
    recruited.assign(data.get("recruited", ["ghost"]))
    if not recruited.has("ghost"):
        recruited.append("ghost")
    selected_team.assign(data.get("selected_team", ["ghost"]))
    selected_team = selected_team.filter(func(id: String): return recruited.has(id)).slice(0, capacity)
    if selected_team.is_empty():
        selected_team = ["ghost"]
