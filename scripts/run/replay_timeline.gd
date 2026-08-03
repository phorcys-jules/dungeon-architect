class_name ReplayTimeline
extends RefCounted

const FORMAT_VERSION := 1
const MAX_EVENTS := 5000
var seed := 0
var game_version := ""
var events: Array[Dictionary] = []
var cursor := 0
var playback_speed := 1.0
var playing := false

func begin(seed_value: int, version: String) -> void:
    seed = seed_value
    game_version = version
    events.clear()
    cursor = 0
    playing = false

func record(time_seconds: float, type: StringName, actor: String, cell: Vector2i, data: Dictionary = {}) -> bool:
    if events.size() >= MAX_EVENTS or time_seconds < 0.0:
        return false
    events.append({"t": snappedf(time_seconds, 0.01), "type": type, "actor": actor, "cell": [cell.x, cell.y], "data": data.duplicate(true)})
    return true

func seek(index: int) -> Dictionary:
    if events.is_empty():
        return {}
    cursor = clampi(index, 0, events.size() - 1)
    return events[cursor].duplicate(true)

func next(filter_actor := "", filter_type: StringName = &"") -> Dictionary:
    while cursor < events.size():
        var event: Dictionary = events[cursor]
        cursor += 1
        if (filter_actor.is_empty() or String(event.actor) == filter_actor) and (filter_type.is_empty() or StringName(event.type) == filter_type):
            return event.duplicate(true)
    return {}

func set_speed(value: float) -> void:
    playback_speed = clampf(value, 0.25, 4.0)

func export_code() -> String:
    var payload := {"format": FORMAT_VERSION, "game_version": game_version, "seed": seed, "events": events}
    return Marshalls.raw_to_base64(JSON.stringify(payload).to_utf8_buffer())

func import_code(code: String, expected_game_version: String) -> Dictionary:
    var parsed: Variant = JSON.parse_string(Marshalls.base64_to_raw(code).get_string_from_utf8())
    if typeof(parsed) != TYPE_DICTIONARY or int(parsed.get("format", 0)) != FORMAT_VERSION:
        return {"ok": false, "reason": "invalid_format"}
    if String(parsed.get("game_version", "")) != expected_game_version:
        return {"ok": false, "reason": "incompatible_version"}
    begin(int(parsed.get("seed", 0)), expected_game_version)
    events.assign(parsed.get("events", []))
    if events.size() > MAX_EVENTS:
        events.resize(MAX_EVENTS)
    return {"ok": true, "events": events.size()}

func estimated_bytes() -> int:
    return JSON.stringify(events).to_utf8_buffer().size()

func to_dict() -> Dictionary:
    return {"format": FORMAT_VERSION, "game_version": game_version, "seed": seed, "events": events.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    if int(data.get("format", 0)) != FORMAT_VERSION:
        return
    begin(int(data.get("seed", 0)), String(data.get("game_version", "")))
    events.assign(data.get("events", []))
