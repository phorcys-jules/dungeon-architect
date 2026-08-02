class_name BiomeCatalog
extends RefCounted

const CRYPT := "crypt"
const MINE := "mine"
const CASTLE := "castle"
const SEWERS := "sewers"

var definitions: Dictionary = {
    CRYPT: {
        "name": "Crypte",
        "tags": ["undead", "dark"],
        "rules": {
            "ghost_speed_multiplier": 1.15,
            "fear_gain_multiplier": 1.2,
            "healing_multiplier": 0.85,
        },
        "construction": {
            "wall_cost_multiplier": 1.0,
            "blocked_room_tags": ["fountain"],
            "required_room_tags": ["grave"],
        },
    },
    MINE: {
        "name": "Mine",
        "tags": ["stone", "narrow"],
        "rules": {
            "trap_damage_multiplier": 1.15,
            "movement_speed_multiplier": 0.95,
            "stone_reward_multiplier": 1.35,
        },
        "construction": {
            "wall_cost_multiplier": 0.8,
            "blocked_room_tags": ["large"],
            "required_room_tags": ["ore"],
        },
    },
    CASTLE: {
        "name": "Château",
        "tags": ["royal", "fortified"],
        "rules": {
            "door_health_multiplier": 1.4,
            "elite_rate_bonus": 0.1,
            "gold_reward_multiplier": 1.2,
        },
        "construction": {
            "wall_cost_multiplier": 1.2,
            "blocked_room_tags": [],
            "required_room_tags": ["guard_post"],
        },
    },
    SEWERS: {
        "name": "Égouts",
        "tags": ["slime", "wet"],
        "rules": {
            "slime_duration_multiplier": 1.35,
            "fire_damage_multiplier": 0.75,
            "poison_damage_multiplier": 1.2,
        },
        "construction": {
            "wall_cost_multiplier": 0.9,
            "blocked_room_tags": ["fire"],
            "required_room_tags": ["drain"],
        },
    },
}

func get_biome(biome_id: String) -> Dictionary:
    if not definitions.has(biome_id):
        return {}
    return definitions[biome_id].duplicate(true)

func all_ids() -> Array[String]:
    var ids: Array[String] = []
    ids.assign(definitions.keys())
    ids.sort()
    return ids

func validate_room_tags(biome_id: String, room_tags: Array[String]) -> Dictionary:
    var biome := get_biome(biome_id)
    if biome.is_empty():
        return {"ok": false, "reason": "unknown_biome"}
    var construction: Dictionary = biome.construction
    for blocked_tag in construction.blocked_room_tags:
        if room_tags.has(String(blocked_tag)):
            return {"ok": false, "reason": "blocked_tag", "tag": blocked_tag}
    return {"ok": true}

func has_required_room(biome_id: String, placed_room_tags: Array[String]) -> bool:
    var biome := get_biome(biome_id)
    if biome.is_empty():
        return false
    var required: Array = biome.construction.required_room_tags
    for tag in required:
        if not placed_room_tags.has(String(tag)):
            return false
    return true
