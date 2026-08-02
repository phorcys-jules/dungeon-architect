class_name BossCatalog
extends RefCounted

var definitions: Dictionary = {
    "paladin_captain": {
        "name": "Capitaine paladin",
        "intro": "Le capitaine jure de reprendre le trésor avant l'aube.",
        "max_health": 650,
        "base_damage": 24,
        "phases": [
            {"threshold": 1.0, "ability": "shield_wall", "damage_multiplier": 1.0},
            {"threshold": 0.65, "ability": "holy_reinforcements", "damage_multiplier": 1.2},
            {"threshold": 0.3, "ability": "last_crusade", "damage_multiplier": 1.5},
        ],
        "reward": {"gold": 180, "essence": 45, "relic_rarity": "rare"},
    },
    "archmage_lux": {
        "name": "Archimage Lux",
        "intro": "La lumière de Lux dissipe les ombres et révèle les passages secrets.",
        "max_health": 520,
        "base_damage": 30,
        "phases": [
            {"threshold": 1.0, "ability": "reveal_dungeon", "damage_multiplier": 1.0},
            {"threshold": 0.6, "ability": "arcane_overload", "damage_multiplier": 1.25},
            {"threshold": 0.25, "ability": "time_stop", "damage_multiplier": 1.55},
        ],
        "reward": {"gold": 140, "essence": 70, "relic_rarity": "rare"},
    },
    "royal_huntress": {
        "name": "Chasseresse royale",
        "intro": "La chasseresse connaît chaque détour et marque les monstres les plus dangereux.",
        "max_health": 580,
        "base_damage": 27,
        "phases": [
            {"threshold": 1.0, "ability": "mark_guardian", "damage_multiplier": 1.0},
            {"threshold": 0.55, "ability": "piercing_volley", "damage_multiplier": 1.3},
            {"threshold": 0.2, "ability": "relentless_hunt", "damage_multiplier": 1.6},
        ],
        "reward": {"gold": 165, "essence": 55, "relic_rarity": "rare"},
    },
}

func get_boss(boss_id: String) -> Dictionary:
    return definitions.get(boss_id, {}).duplicate(true)

func ids() -> Array[String]:
    var result: Array[String] = []
    for boss_id in definitions:
        result.append(String(boss_id))
    result.sort()
    return result

func select_for_seed(run_seed: int) -> String:
    var boss_ids := ids()
    if boss_ids.is_empty():
        return ""
    return boss_ids[abs(run_seed) % boss_ids.size()]
