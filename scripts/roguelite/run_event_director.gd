class_name RunEventDirector
extends RefCounted

var catalog := RunEventCatalog.new()
var active_events: Array[Dictionary] = []
var history: Array[String] = []

func roll(seed: int, depth: int, biome_id: String) -> Dictionary:
    var active_ids: Array[String] = []
    for event in active_events:
        active_ids.append(String(event.id))
    var candidates := catalog.eligible(depth, biome_id, active_ids)
    if candidates.is_empty():
        return {}
    var total_weight := 0
    for event_id in candidates:
        total_weight += int(catalog.definitions[event_id].weight)
    var rng := RandomNumberGenerator.new()
    rng.seed = seed + depth * 7919 + history.size() * 101
    var target := rng.randi_range(1, total_weight)
    var cursor := 0
    for event_id in candidates:
        cursor += int(catalog.definitions[event_id].weight)
        if target <= cursor:
            return _activate(event_id)
    return {}

func tick_stage() -> Array[String]:
    var expired: Array[String] = []
    for event in active_events:
        event.remaining = int(event.remaining) - 1
        if int(event.remaining) <= 0:
            expired.append(String(event.id))
    active_events = active_events.filter(func(event: Dictionary): return int(event.remaining) > 0)
    return expired

func combined_effects() -> Dictionary:
    var result := {}
    for event in active_events:
        var effects: Dictionary = event.effects
        for key in effects:
            var value = effects[key]
            if String(key).ends_with("_multiplier"):
                result[key] = float(result.get(key, 1.0)) * float(value)
            else:
                result[key] = float(result.get(key, 0.0)) + float(value)
    return result

func announcement(event: Dictionary) -> Dictionary:
    if event.is_empty():
        return {}
    return {
        "title": String(event.name),
        "body": String(event.description),
        "duration": int(event.remaining),
    }

func to_dict() -> Dictionary:
    return {"active_events": active_events.duplicate(true), "history": history.duplicate()}

func from_dict(data: Dictionary) -> void:
    active_events.assign(data.get("active_events", []))
    history.assign(data.get("history", []))

func _activate(event_id: String) -> Dictionary:
    var data := catalog.get_event(event_id)
    if data.is_empty():
        return {}
    var event := {
        "id": event_id,
        "name": data.name,
        "description": data.description,
        "effects": data.effects.duplicate(true),
        "remaining": int(data.duration),
    }
    active_events.append(event)
    history.append(event_id)
    return event.duplicate(true)
