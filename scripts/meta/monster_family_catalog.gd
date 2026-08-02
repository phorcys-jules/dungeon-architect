class_name MonsterFamilyCatalog
extends RefCounted

const FAMILIES := {
    "spectral": {"tags": ["ghost", "ethereal"], "affinity": "mist", "bonus": {"speed_multiplier": 1.08}},
    "slime": {"tags": ["slime", "ooze"], "affinity": "pool", "bonus": {"health_multiplier": 1.1}},
    "beast": {"tags": ["spider", "beast"], "affinity": "web", "bonus": {"cooperation_bonus": 0.15}},
    "construct": {"tags": ["guardian", "construct"], "affinity": "forge", "bonus": {"damage_multiplier": 1.08}},
}

func get_family(family_id: String) -> Dictionary:
    return (FAMILIES.get(family_id, {}) as Dictionary).duplicate(true)

func team_affinities(families: Array[String]) -> Dictionary:
    var counts := {}
    for family_id in families:
        counts[family_id] = int(counts.get(family_id, 0)) + 1
    var active := {}
    for family_id in counts:
        if int(counts[family_id]) >= 2 and FAMILIES.has(family_id):
            active[family_id] = get_family(str(family_id)).get("bonus", {})
    return active
