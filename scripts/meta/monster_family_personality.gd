class_name MonsterFamilyPersonality
extends RefCounted

const FAMILIES := {
    "spectral": {"tags": ["ghost", "ethereal"], "affinity": "fog", "bonus": {"speed": 1.1}},
    "beast": {"tags": ["spider", "beast"], "affinity": "web", "bonus": {"damage": 1.12}},
    "ooze": {"tags": ["slime", "ooze"], "affinity": "pool", "bonus": {"trap_damage": 1.15}},
    "construct": {"tags": ["guardian", "construct"], "affinity": "forge", "bonus": {"health": 1.15}},
}

const PERSONALITIES := {
    "aggressive": {"category": "positive", "damage": 1.15, "health": 0.95, "target_bias": "nearest"},
    "cautious": {"category": "mixed", "damage": 0.95, "health": 1.15, "target_bias": "safe"},
    "loyal": {"category": "positive", "damage": 1.0, "health": 1.1, "target_bias": "treasure"},
    "cunning": {"category": "positive", "damage": 1.05, "health": 1.0, "target_bias": "intercept"},
    "greedy": {"category": "mixed", "damage": 1.08, "health": 0.95, "target_bias": "loot"},
    "fragile": {"category": "negative", "damage": 1.0, "health": 0.82, "target_bias": "safe"},
    "clumsy": {"category": "negative", "damage": 0.9, "health": 1.0, "speed": 0.88, "target_bias": "nearest"},
}

func family_definition(family: String) -> Dictionary:
    return Dictionary(FAMILIES.get(family, {})).duplicate(true)

func generate_traits(seed_value: int, count: int = 2) -> Array[String]:
    var ids: Array = PERSONALITIES.keys()
    ids.sort()
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value
    var result: Array[String] = []
    while result.size() < mini(maxi(count, 0), ids.size()):
        var candidate := String(ids[rng.randi_range(0, ids.size() - 1)])
        if not result.has(candidate):
            result.append(candidate)
    return result

func active_affinities(families: Array[String]) -> Dictionary:
    var counts := {}
    for family in families:
        counts[family] = int(counts.get(family, 0)) + 1
    var result := {}
    for family in counts:
        if int(counts[family]) >= 2 and FAMILIES.has(family):
            result[family] = family_definition(String(family)).get("bonus", {})
    return result

func family_bonus(families: Array[String]) -> Dictionary:
    var counts := {}
    for family in families:
        counts[family] = int(counts.get(family, 0)) + 1
    var result := {"health": 1.0, "damage": 1.0, "speed": 1.0, "trap_damage": 1.0}
    for family in counts:
        var count := int(counts[family])
        if count < 2:
            continue
        match family:
            "spectral": result.speed = float(result.speed) * (1.1 if count == 2 else 1.2)
            "beast": result.damage = float(result.damage) * (1.12 if count == 2 else 1.22)
            "ooze": result.trap_damage = float(result.trap_damage) * (1.15 if count == 2 else 1.3)
            "construct": result.health = float(result.health) * (1.15 if count == 2 else 1.3)
    return result

func personality_modifiers(personality: String) -> Dictionary:
    return Dictionary(PERSONALITIES.get(personality, {"category": "neutral", "damage": 1.0, "health": 1.0, "target_bias": "nearest"})).duplicate(true)

func combined_trait_modifiers(traits: Array[String]) -> Dictionary:
    var result := {"health": 1.0, "damage": 1.0, "speed": 1.0}
    for trait_id in traits:
        var modifiers := personality_modifiers(trait_id)
        for key in ["health", "damage", "speed"]:
            result[key] = float(result[key]) * float(modifiers.get(key, 1.0))
    return result

func target_bias(personality: String) -> String:
    return String(personality_modifiers(personality).target_bias)
