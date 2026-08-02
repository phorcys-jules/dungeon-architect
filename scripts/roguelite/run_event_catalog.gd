class_name RunEventCatalog
extends RefCounted

var definitions := {
    "royal_visit": {
        "name": "Arrivée du roi",
        "description": "Les aventuriers royaux arrivent mieux équipés, mais les récompenses augmentent.",
        "weight": 6,
        "min_depth": 3,
        "biomes": [],
        "incompatible": ["total_darkness"],
        "duration": 2,
        "effects": {"adventurer_health_multiplier": 1.2, "reward_multiplier": 1.35},
    },
    "drunken_monsters": {
        "name": "Monstres ivres",
        "description": "Les monstres frappent plus fort mais se déplacent moins vite.",
        "weight": 10,
        "min_depth": 1,
        "biomes": [],
        "incompatible": [],
        "duration": 2,
        "effects": {"monster_damage_multiplier": 1.25, "monster_speed_multiplier": 0.8},
    },
    "accelerated_traps": {
        "name": "Pièges accélérés",
        "description": "Les pièges se rechargent plus vite pendant cette étape.",
        "weight": 9,
        "min_depth": 1,
        "biomes": ["mine", "castle"],
        "incompatible": [],
        "duration": 2,
        "effects": {"trap_cooldown_multiplier": 0.65},
    },
    "total_darkness": {
        "name": "Obscurité totale",
        "description": "La vision des aventuriers est fortement réduite.",
        "weight": 7,
        "min_depth": 2,
        "biomes": ["crypt", "sewers"],
        "incompatible": ["royal_visit", "torch_bearers"],
        "duration": 3,
        "effects": {"vision_multiplier": 0.45, "fear_gain_multiplier": 1.3},
    },
    "torch_bearers": {
        "name": "Porteurs de torches",
        "description": "Les aventuriers résistent mieux à l'obscurité et à la peur.",
        "weight": 8,
        "min_depth": 2,
        "biomes": ["crypt", "mine", "sewers"],
        "incompatible": ["total_darkness"],
        "duration": 2,
        "effects": {"vision_multiplier": 1.35, "fear_gain_multiplier": 0.75},
    },
    "exceptional_invasion": {
        "name": "Invasion exceptionnelle",
        "description": "Une vague supplémentaire arrive avec davantage d'aventuriers.",
        "weight": 5,
        "min_depth": 4,
        "biomes": [],
        "incompatible": [],
        "duration": 1,
        "effects": {"adventurer_count_bonus": 2, "reward_multiplier": 1.5},
    },
}

func eligible(depth: int, biome_id: String, active_ids: Array[String]) -> Array[String]:
    var result: Array[String] = []
    for event_id in definitions:
        var data: Dictionary = definitions[event_id]
        if depth < int(data.min_depth):
            continue
        var biomes: Array = data.biomes
        if not biomes.is_empty() and not biomes.has(biome_id):
            continue
        var blocked := false
        for active_id in active_ids:
            if data.incompatible.has(active_id):
                blocked = true
                break
            var active: Dictionary = definitions.get(active_id, {})
            if active.get("incompatible", []).has(event_id):
                blocked = true
                break
        if not blocked:
            result.append(String(event_id))
    return result

func get_event(event_id: String) -> Dictionary:
    return definitions.get(event_id, {}).duplicate(true)
