class_name MonsterFamilyPersonality
extends RefCounted

var personalities := {
    "aggressive": {"damage": 1.15, "health": 0.95, "target_bias": "nearest"},
    "cautious": {"damage": 0.95, "health": 1.15, "target_bias": "safe"},
    "loyal": {"damage": 1.0, "health": 1.1, "target_bias": "treasure"},
    "cunning": {"damage": 1.05, "health": 1.0, "target_bias": "intercept"},
    "greedy": {"damage": 1.0, "health": 1.0, "target_bias": "loot"},
}

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
    return Dictionary(personalities.get(personality, {"damage": 1.0, "health": 1.0, "target_bias": "nearest"})).duplicate(true)

func target_bias(personality: String) -> String:
    return String(personality_modifiers(personality).target_bias)
