class_name MonsterTraits
extends RefCounted

const TRAITS := {
    "brave": {"fear_resistance": 0.25, "damage_multiplier": 1.05},
    "coward": {"fear_resistance": -0.2, "speed_multiplier": 1.1},
    "loyal": {"cooperation_bonus": 0.2},
    "solitary": {"cooperation_bonus": -0.15, "damage_multiplier": 1.1},
    "nimble": {"speed_multiplier": 1.15, "health_multiplier": 0.9},
    "stubborn": {"health_multiplier": 1.2, "speed_multiplier": 0.9},
}

var assigned: Array[String] = []

func generate(seed_value: int, count: int = 2) -> Array[String]:
    var keys: Array = TRAITS.keys()
    keys.sort()
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value
    assigned.clear()
    while assigned.size() < mini(count, keys.size()):
        var candidate := str(keys[rng.randi_range(0, keys.size() - 1)])
        if not assigned.has(candidate):
            assigned.append(candidate)
    return assigned.duplicate()

func set_traits(values: Array[String]) -> void:
    assigned.clear()
    for value in values:
        if TRAITS.has(value) and not assigned.has(value):
            assigned.append(value)

func combined_modifiers() -> Dictionary:
    var result := {
        "health_multiplier": 1.0,
        "damage_multiplier": 1.0,
        "speed_multiplier": 1.0,
        "fear_resistance": 0.0,
        "cooperation_bonus": 0.0,
    }
    for trait_id in assigned:
        var modifiers: Dictionary = TRAITS[trait_id]
        for key in modifiers:
            if str(key).ends_with("_multiplier"):
                result[key] = float(result.get(key, 1.0)) * float(modifiers[key])
            else:
                result[key] = float(result.get(key, 0.0)) + float(modifiers[key])
    return result

func to_dict() -> Dictionary:
    return {"assigned": assigned.duplicate()}

func from_dict(data: Dictionary) -> void:
    var values: Array[String] = []
    for value in data.get("assigned", []):
        values.append(str(value))
    set_traits(values)
