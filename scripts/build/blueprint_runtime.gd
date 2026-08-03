class_name BlueprintRuntime
extends RefCounted

const FORMAT_VERSION := 1
var blueprints: Dictionary = {}

func capture(id: String, placements: Array[Dictionary], origin: Vector2i) -> bool:
    if id.is_empty() or placements.is_empty():
        return false
    var relative: Array[Dictionary] = []
    for placement in placements:
        relative.append({"offset": Vector2i(placement.cell) - origin, "kind": String(placement.kind), "content_id": String(placement.get("content_id", "")), "cost": int(placement.get("cost", 0))})
    blueprints[id] = {"version": FORMAT_VERSION, "placements": relative}
    return true

func preview(id: String, origin: Vector2i, rotation := 0, mirror := false, blocked: Array[Vector2i] = []) -> Dictionary:
    if not blueprints.has(id):
        return {"ok": false, "reason": "unknown_blueprint", "placements": []}
    var result: Array[Dictionary] = []
    var cost := 0
    var invalid := 0
    for entry in blueprints[id].placements:
        var offset := _transform(Vector2i(entry.offset), rotation, mirror)
        var cell := origin + offset
        var valid := not blocked.has(cell)
        invalid += 0 if valid else 1
        cost += int(entry.cost) if valid else 0
        var copy: Dictionary = entry.duplicate(true)
        copy["cell"] = cell
        copy["valid"] = valid
        result.append(copy)
    return {"ok": invalid == 0, "placements": result, "cost": cost, "invalid": invalid}

func validate_purchase(preview_result: Dictionary, available_currency: int, route_valid: bool, unlocked_ids: Array[String]) -> Dictionary:
    if not route_valid:
        return {"ok": false, "reason": "route_blocked"}
    if int(preview_result.get("cost", 0)) > available_currency:
        return {"ok": false, "reason": "not_enough_currency"}
    for entry in preview_result.get("placements", []):
        if not bool(entry.valid):
            return {"ok": false, "reason": "invalid_cell"}
        if not String(entry.content_id).is_empty() and not unlocked_ids.has(String(entry.content_id)):
            return {"ok": false, "reason": "locked_content"}
    return {"ok": true, "cost": int(preview_result.cost)}

func export_challenge(seed_value: int, campaign_state: Dictionary = {}) -> String:
    return Marshalls.raw_to_base64(JSON.stringify({"version": FORMAT_VERSION, "seed": seed_value, "campaign": campaign_state}).to_utf8_buffer())

func import_challenge(value: String) -> Dictionary:
    var parsed: Variant = JSON.parse_string(Marshalls.base64_to_raw(value).get_string_from_utf8())
    if typeof(parsed) != TYPE_DICTIONARY or int(parsed.get("version", 0)) != FORMAT_VERSION:
        return {"ok": false, "reason": "incompatible_format"}
    return {"ok": true, "seed": int(parsed.get("seed", 0)), "campaign": Dictionary(parsed.get("campaign", {})).duplicate(true)}

func _transform(offset: Vector2i, rotation: int, mirror: bool) -> Vector2i:
    var value := Vector2i(-offset.x, offset.y) if mirror else offset
    for ignored in posmod(rotation, 4):
        value = Vector2i(-value.y, value.x)
    return value

func to_dict() -> Dictionary:
    return {"blueprints": blueprints.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    blueprints = Dictionary(data.get("blueprints", {})).duplicate(true)
