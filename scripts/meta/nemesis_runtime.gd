class_name NemesisRuntime
extends RefCounted

const MAX_ADAPTATIONS := 3
var rivals: Dictionary = {}

func promote(adventurer_id: String, display_name: String, run_result: Dictionary) -> Dictionary:
    if rivals.has(adventurer_id):
        return rivals[adventurer_id].duplicate(true)
    var rival := {"id": adventurer_id, "name": display_name, "title": "Voleur du trésor" if bool(run_result.get("stole_treasure", false)) else "Survivant", "encounters": 1, "scars": [], "observations": {}, "adaptations": [], "defeated": false}
    rivals[adventurer_id] = rival
    record_encounter(adventurer_id, run_result)
    return rivals[adventurer_id].duplicate(true)

func record_encounter(adventurer_id: String, result: Dictionary) -> void:
    if not rivals.has(adventurer_id):
        return
    var rival: Dictionary = rivals[adventurer_id]
    rival.encounters = int(rival.encounters) + 1
    for trap_id in result.get("trap_ids", []):
        var key := "trap:%s" % String(trap_id)
        rival.observations[key] = int(rival.observations.get(key, 0)) + 1
    for monster_id in result.get("monster_ids", []):
        var key := "monster:%s" % String(monster_id)
        rival.observations[key] = int(rival.observations.get(key, 0)) + 1
    _learn(rival)
    rivals[adventurer_id] = rival

func _learn(rival: Dictionary) -> void:
    var ranked: Array = rival.observations.keys()
    ranked.sort_custom(func(a, b): return int(rival.observations[a]) > int(rival.observations[b]))
    rival.adaptations.clear()
    for key in ranked.slice(0, MAX_ADAPTATIONS):
        rival.adaptations.append({"observed": key, "counter": _counter_for(String(key)), "source_count": rival.observations[key]})

func _counter_for(observed: String) -> String:
    if observed.begins_with("trap:"):
        return "disarm:%s" % observed.trim_prefix("trap:")
    return "ward:%s" % observed.trim_prefix("monster:")

func defeat(adventurer_id: String) -> Dictionary:
    if not rivals.has(adventurer_id):
        return {"ok": false}
    rivals[adventurer_id].defeated = true
    return {"ok": true, "reward": {"essence": 35, "bones": 20}, "title": rivals[adventurer_id].title}

func report(adventurer_id: String, laboratory_level: int) -> Dictionary:
    if not rivals.has(adventurer_id):
        return {}
    var rival: Dictionary = rivals[adventurer_id]
    return {"name": rival.name, "title": rival.title, "encounters": rival.encounters, "adaptations": rival.adaptations.slice(0, clampi(laboratory_level, 0, MAX_ADAPTATIONS)), "hidden": maxi(rival.adaptations.size() - laboratory_level, 0)}

func to_dict() -> Dictionary:
    return {"rivals": rivals.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    rivals = Dictionary(data.get("rivals", {})).duplicate(true)
