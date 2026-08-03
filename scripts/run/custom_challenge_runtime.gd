class_name CustomChallengeRuntime
extends RefCounted

const FORMAT_VERSION := 1
const MUTATORS := {
    &"scarce_currency": {"points": 2, "effects": {"starting_currency_multiplier": 0.65}, "incompatible": [&"abundant_currency"]},
    &"abundant_currency": {"points": -1, "effects": {"starting_currency_multiplier": 1.4}, "incompatible": [&"scarce_currency"]},
    &"volatile_environment": {"points": 2, "effects": {"environment_rate_multiplier": 1.5}, "incompatible": []},
    &"fragile_monsters": {"points": 2, "effects": {"monster_health_multiplier": 0.75}, "incompatible": [&"armored_monsters"]},
    &"armored_monsters": {"points": -1, "effects": {"monster_health_multiplier": 1.35}, "incompatible": [&"fragile_monsters"]},
    &"fast_adventurers": {"points": 3, "effects": {"adventurer_speed_multiplier": 1.25}, "incompatible": []},
    &"total_fog": {"points": 2, "effects": {"vision_multiplier": 0.45}, "incompatible": []},
}

var configuration: Dictionary = {}

func configure(seed_value: int, biome: StringName, faction: StringName, boss: String, mutators: Array[StringName], restrictions: Dictionary = {}) -> Dictionary:
    for mutator in mutators:
        if not MUTATORS.has(mutator):
            return {"ok": false, "reason": "unknown_mutator", "mutator": mutator}
    for left in mutators:
        for right in MUTATORS[left].incompatible:
            if mutators.has(right):
                return {"ok": false, "reason": "incompatible_mutators", "pair": [left, right]}
    configuration = {"format": FORMAT_VERSION, "seed": seed_value, "biome": biome, "faction": faction, "boss": boss, "mutators": mutators.duplicate(), "restrictions": restrictions.duplicate(true), "persistent_rewards": false}
    configuration["score_multiplier"] = score_multiplier()
    return {"ok": true, "configuration": configuration.duplicate(true)}

func score_multiplier() -> float:
    var points := 0
    for mutator in configuration.get("mutators", []):
        points += int(MUTATORS.get(mutator, {}).get("points", 0))
    return maxf(0.25, 1.0 + float(points) * 0.15)

func combined_effects() -> Dictionary:
    var result := {}
    for mutator in configuration.get("mutators", []):
        for key in MUTATORS[mutator].effects:
            result[key] = float(result.get(key, 1.0)) * float(MUTATORS[mutator].effects[key])
    return result

func validate_unlocks(unlocked_ids: Array[String]) -> Dictionary:
    for category in ["required", "forbidden"]:
        for content_id in configuration.get("restrictions", {}).get(category, []):
            if category == "required" and not unlocked_ids.has(String(content_id)):
                return {"ok": false, "reason": "locked_content", "content_id": content_id}
    return {"ok": true}

func export_code() -> String:
    var json := JSON.stringify(configuration)
    var envelope := {"payload": json, "checksum": _checksum(json)}
    return Marshalls.raw_to_base64(JSON.stringify(envelope).to_utf8_buffer())

func import_code(code: String) -> Dictionary:
    var envelope: Variant = JSON.parse_string(Marshalls.base64_to_raw(code).get_string_from_utf8())
    if typeof(envelope) != TYPE_DICTIONARY:
        return {"ok": false, "reason": "invalid_code"}
    var payload := String(envelope.get("payload", ""))
    if int(envelope.get("checksum", -1)) != _checksum(payload):
        return {"ok": false, "reason": "checksum_mismatch"}
    var parsed: Variant = JSON.parse_string(payload)
    if typeof(parsed) != TYPE_DICTIONARY or int(parsed.get("format", 0)) != FORMAT_VERSION:
        return {"ok": false, "reason": "incompatible_format"}
    configuration = Dictionary(parsed).duplicate(true)
    return {"ok": true, "configuration": configuration.duplicate(true)}

func _checksum(value: String) -> int:
    return abs(value.hash())

func to_dict() -> Dictionary:
    return configuration.duplicate(true)

func from_dict(data: Dictionary) -> void:
    configuration = data.duplicate(true) if int(data.get("format", 0)) == FORMAT_VERSION else {}
