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
        "palette": {"floor_a": "211c2b", "floor_b": "191622", "grid": "514564", "wall": "62536f", "accent": "b995d6"},
        "rules": {
            "monster_speed_multiplier": 1.10,
        },
        "construction": {
            "wall_cost_multiplier": 1.0,
            "blocked_room_tags": ["fountain"],
            "required_room_tags": ["curse"],
        },
    },
    MINE: {
        "name": "Mine",
        "tags": ["stone", "narrow"],
        "palette": {"floor_a": "2c2925", "floor_b": "25221f", "grid": "5b5144", "wall": "716452", "accent": "d4a95d"},
        "rules": {
            "trap_damage_multiplier": 1.15,
            "movement_speed_multiplier": 0.95,
        },
        "construction": {
            "wall_cost_multiplier": 0.8,
            "blocked_room_tags": ["large"],
            "required_room_tags": ["corridor"],
        },
    },
    CASTLE: {
        "name": "Château",
        "tags": ["royal", "fortified"],
        "palette": {"floor_a": "252b3a", "floor_b": "202533", "grid": "4d5b78", "wall": "667798", "accent": "f4d35e"},
        "rules": {
            "starting_gold_adjustment": 15.0,
        },
        "construction": {
            "wall_cost_multiplier": 1.2,
            "blocked_room_tags": [],
            "required_room_tags": ["control"],
        },
    },
    SEWERS: {
        "name": "Égouts",
        "tags": ["slime", "wet"],
        "palette": {"floor_a": "1d302b", "floor_b": "172722", "grid": "395b50", "wall": "4f7969", "accent": "77d68c"},
        "rules": {
            "effect_duration_multiplier": 1.25,
            "movement_speed_multiplier": 0.92,
        },
        "construction": {
            "wall_cost_multiplier": 0.9,
            "blocked_room_tags": ["fire"],
            "required_room_tags": ["slime"],
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
