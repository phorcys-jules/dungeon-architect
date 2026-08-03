class_name TacticalIntentRuntime
extends RefCounted

const TYPES := [&"chase", &"flee", &"sabotage", &"steal", &"attack"]

var intents: Dictionary = {}

func announce(actor_id: String, type: StringName, origin: Vector2i, target: Vector2i, delay: float) -> Dictionary:
    if actor_id.is_empty() or not TYPES.has(type) or delay < 0.0:
        return {"ok": false, "reason": "invalid_intent"}
    var intent := {
        "actor": actor_id,
        "type": type,
        "origin": origin,
        "target": target,
        "delay": snappedf(delay, 0.05),
        "symbol": _symbol(type),
        "shape": _shape(type),
    }
    intents[actor_id] = intent
    return {"ok": true, "intent": intent.duplicate(true)}

func update(delta: float) -> Array[String]:
    var expired: Array[String] = []
    for actor_id in intents.keys():
        var intent: Dictionary = intents[actor_id]
        intent.delay = maxf(0.0, float(intent.delay) - delta)
        if is_zero_approx(float(intent.delay)):
            expired.append(String(actor_id))
            intents.erase(actor_id)
        else:
            intents[actor_id] = intent
    return expired

func threat_cells() -> Dictionary:
    var result := {}
    for intent in intents.values():
        var target: Vector2i = intent.target
        result[target] = maxf(float(result.get(target, 0.0)), _weight(StringName(intent.type)))
    return result

func clear_actor(actor_id: String) -> void:
    intents.erase(actor_id)

func _symbol(type: StringName) -> String:
    return {&"chase": "→", &"flee": "↩", &"sabotage": "!", &"steal": "$", &"attack": "×"}.get(type, "?")

func _shape(type: StringName) -> StringName:
    return {&"chase": &"arrow", &"flee": &"double_arrow", &"sabotage": &"diamond", &"steal": &"hexagon", &"attack": &"cross"}.get(type, &"circle")

func _weight(type: StringName) -> float:
    return {&"steal": 1.0, &"sabotage": 0.9, &"attack": 0.75, &"chase": 0.5, &"flee": 0.2}.get(type, 0.0)

func to_dict() -> Dictionary:
    var serialized := {}
    for actor_id in intents:
        var intent: Dictionary = intents[actor_id]
        var origin: Vector2i = intent.origin
        var target: Vector2i = intent.target
        serialized[actor_id] = {
            "actor": String(intent.actor),
            "type": String(intent.type),
            "origin": [origin.x, origin.y],
            "target": [target.x, target.y],
            "delay": float(intent.delay),
            "symbol": String(intent.symbol),
            "shape": String(intent.shape),
        }
    return {"intents": serialized}

func from_dict(data: Dictionary) -> void:
    intents.clear()
    for actor_id in Dictionary(data.get("intents", {})):
        var saved: Dictionary = data.intents[actor_id]
        var origin_value: Variant = saved.get("origin", [])
        var target_value: Variant = saved.get("target", [])
        var type := StringName(saved.get("type", ""))
        if not origin_value is Array or not target_value is Array or not TYPES.has(type):
            continue
        var origin: Array = origin_value
        var target: Array = target_value
        if origin.size() != 2 or target.size() != 2:
            continue
        announce(String(actor_id), type, Vector2i(int(origin[0]), int(origin[1])), Vector2i(int(target[0]), int(target[1])), maxf(float(saved.get("delay", 0.0)), 0.0))
