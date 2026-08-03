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
    return {"intents": intents.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    intents = Dictionary(data.get("intents", {})).duplicate(true)
