class_name RunChallengeCatalog
extends RefCounted

var definitions := {
    "no_traps": {
        "name": "Sans pièges",
        "description": "Terminer la run sans placer de piège.",
        "metric": "traps_placed",
        "comparison": "equal",
        "target": 0,
        "reward": {"gold": 45, "essence": 8},
    },
    "pacifist_capture": {
        "name": "Capture propre",
        "description": "Capturer un aventurier sans lui infliger de dégâts directs.",
        "metric": "direct_damage",
        "comparison": "equal",
        "target": 0,
        "requires": {"captures": 1},
        "reward": {"gold": 55, "essence": 10},
    },
    "single_family": {
        "name": "Une seule famille",
        "description": "Gagner avec une équipe composée d'une seule famille de monstres.",
        "metric": "monster_families",
        "comparison": "max",
        "target": 1,
        "reward": {"gold": 50, "essence": 9},
    },
    "perfect_hoard": {
        "name": "Trésor intact",
        "description": "Protéger toutes les ressources du donjon.",
        "metric": "resources_lost",
        "comparison": "equal",
        "target": 0,
        "reward": {"gold": 60, "essence": 12},
    },
    "wall_minimalist": {
        "name": "Architecte minimaliste",
        "description": "Terminer avec au plus six murs construits.",
        "metric": "walls_placed",
        "comparison": "max",
        "target": 6,
        "reward": {"gold": 40, "essence": 7},
    },
    "untouched_monsters": {
        "name": "Aucune perte",
        "description": "Terminer sans perdre de monstre.",
        "metric": "monsters_lost",
        "comparison": "equal",
        "target": 0,
        "reward": {"gold": 65, "essence": 13},
    },
}

func get_definition(challenge_id: String) -> Dictionary:
    if not definitions.has(challenge_id):
        return {}
    var result: Dictionary = definitions[challenge_id].duplicate(true)
    result["id"] = challenge_id
    return result

func all_ids() -> Array[String]:
    var result: Array[String] = []
    result.assign(definitions.keys())
    result.sort()
    return result

func pick(seed: int, count: int = 3) -> Array[Dictionary]:
    var ids := all_ids()
    var rng := RandomNumberGenerator.new()
    rng.seed = seed
    for index in range(ids.size() - 1, 0, -1):
        var swap_index := rng.randi_range(0, index)
        var value := ids[index]
        ids[index] = ids[swap_index]
        ids[swap_index] = value
    var result: Array[Dictionary] = []
    for index in mini(count, ids.size()):
        result.append(get_definition(ids[index]))
    return result
