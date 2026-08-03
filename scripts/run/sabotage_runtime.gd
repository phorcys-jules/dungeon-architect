class_name SabotageRuntime
extends RefCounted

const ACTIONS := {
    &"sun_order": [&"purify_trap", &"prepare_breach"],
    &"free_blades": [&"steal_key", &"map_portal"],
    &"arcane_circle": [&"invert_portal", &"dispel_room"],
}
const COUNTERS := {&"purify_trap": &"decoy", &"prepare_breach": &"guardian", &"steal_key": &"prison", &"map_portal": &"darkness", &"invert_portal": &"silence", &"dispel_room": &"counterspell"}

var pending: Dictionary = {}
var history: Array[Dictionary] = []

func schedule(seed_value: int, faction: StringName, targets: Array[Dictionary], intelligence_level: int) -> Dictionary:
    var actions: Array = ACTIONS.get(faction, [&"purify_trap"])
    var action: StringName = actions[abs(seed_value) % actions.size()]
    var valid_targets := targets.filter(func(entry: Dictionary): return bool(entry.get("valid", true)))
    if valid_targets.is_empty():
        return {"ok": false, "reason": "no_target"}
    valid_targets.sort_custom(func(a: Dictionary, b: Dictionary): return String(a.get("id", "")) < String(b.get("id", "")))
    var target: Dictionary = valid_targets[abs(seed_value / 7) % valid_targets.size()]
    pending = {"action": action, "target": target, "counter": COUNTERS[action], "delay": 3.0, "certainty": clampf(0.35 + intelligence_level * 0.15, 0.35, 0.95), "faction": faction}
    return {"ok": true, "preview": preview(intelligence_level)}

func preview(intelligence_level: int) -> Dictionary:
    if pending.is_empty():
        return {}
    return {"action": pending.action if intelligence_level >= 1 else "unknown", "target": pending.target if intelligence_level >= 2 else {"kind": pending.target.get("kind", "unknown")}, "counter": pending.counter if intelligence_level >= 3 else "unknown", "delay": pending.delay, "certainty": pending.certainty}

func resolve(active_counters: Array[StringName], route_valid: bool) -> Dictionary:
    if pending.is_empty():
        return {"ok": false, "reason": "no_sabotage"}
    var blocked := active_counters.has(StringName(pending.counter))
    var result := {"ok": true, "blocked": blocked, "action": pending.action, "target": pending.target, "effect": "countered" if blocked else _effect(StringName(pending.action))}
    if not blocked and not route_valid and pending.action == &"prepare_breach":
        result.effect = "revealed_only"
        result["safe_fallback"] = true
    history.append(result.duplicate(true))
    pending.clear()
    return result

func _effect(action: StringName) -> String:
    return {&"purify_trap": "disable_trap", &"prepare_breach": "breach_wall", &"steal_key": "lock_door", &"map_portal": "portal_known", &"invert_portal": "reverse_portal", &"dispel_room": "disable_room_rule"}.get(action, "none")

func to_dict() -> Dictionary:
    return {"pending": pending.duplicate(true), "history": history.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    pending = Dictionary(data.get("pending", {})).duplicate(true)
    history.assign(data.get("history", []))
