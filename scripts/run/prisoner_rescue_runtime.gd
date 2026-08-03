class_name PrisonerRescueRuntime
extends RefCounted

var active: Dictionary = {}
var history: Array[Dictionary] = []

func schedule(seed_value: int, prisoner: Dictionary, faction: StringName, reachable_cells: Array[Vector2i]) -> Dictionary:
    if prisoner.is_empty() or reachable_cells.is_empty() or not active.is_empty():
        return {"ok": false, "reason": "rescue_unavailable"}
    var cell := reachable_cells[posmod(seed_value, reachable_cells.size())]
    active = {
        "id": "rescue_%d" % abs(seed_value),
        "prisoner_id": String(prisoner.get("id", "")),
        "faction": faction,
        "cell": cell,
        "turns": 3 + posmod(seed_value, 3),
        "responses": [&"guard", &"decoy", &"negotiate"],
        "announced": true,
    }
    return {"ok": true, "event": active.duplicate(true)}

func resolve(outcome: StringName) -> Dictionary:
    if active.is_empty() or not [&"defended", &"rescued", &"released"].has(outcome):
        return {"ok": false, "reason": "invalid_outcome"}
    var result := active.duplicate(true)
    result["outcome"] = outcome
    result["reward"] = 25 if outcome == &"defended" else 0
    history.append(result)
    active.clear()
    return {"ok": true, "result": result}

func to_dict() -> Dictionary:
    return {"active": active.duplicate(true), "history": history.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    active = Dictionary(data.get("active", {})).duplicate(true)
    history.assign(data.get("history", []))
