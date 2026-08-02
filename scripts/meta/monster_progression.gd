class_name MonsterProgression
extends RefCounted

const MAX_LEVEL := 10

var monsters: Dictionary = {}

func ensure_monster(monster_id: String, family: String, personality: String) -> void:
    if monsters.has(monster_id):
        return
    monsters[monster_id] = {
        "level": 1,
        "experience": 0,
        "family": family,
        "personality": personality,
        "evolution": "base",
    }

func experience_required(level: int) -> int:
    return 75 + maxi(level - 1, 0) * 50

func grant_experience(monster_id: String, amount: int) -> Dictionary:
    if not monsters.has(monster_id) or amount <= 0:
        return {"levels_gained": 0, "level": 0}
    var entry: Dictionary = monsters[monster_id]
    entry.experience = int(entry.experience) + amount
    var gained := 0
    while int(entry.level) < MAX_LEVEL and int(entry.experience) >= experience_required(int(entry.level)):
        entry.experience = int(entry.experience) - experience_required(int(entry.level))
        entry.level = int(entry.level) + 1
        gained += 1
    monsters[monster_id] = entry
    return {"levels_gained": gained, "level": int(entry.level)}

func choose_evolution(monster_id: String, evolution_id: String) -> bool:
    if not monsters.has(monster_id):
        return false
    var entry: Dictionary = monsters[monster_id]
    if int(entry.level) < 5 or String(entry.evolution) != "base":
        return false
    if not available_evolutions(String(entry.family)).has(evolution_id):
        return false
    entry.evolution = evolution_id
    monsters[monster_id] = entry
    return true

func available_evolutions(family: String) -> Array[String]:
    match family:
        "spectral": return ["wraith", "poltergeist"]
        "beast": return ["alpha", "stalker"]
        "ooze": return ["corrosive", "replicating"]
        "construct": return ["bulwark", "sentinel"]
        _: return []

func stat_multipliers(monster_id: String) -> Dictionary:
    if not monsters.has(monster_id):
        return {"health": 1.0, "damage": 1.0, "speed": 1.0}
    var entry: Dictionary = monsters[monster_id]
    var level_bonus := float(int(entry.level) - 1) * 0.04
    var result := {"health": 1.0 + level_bonus, "damage": 1.0 + level_bonus, "speed": 1.0}
    match String(entry.evolution):
        "wraith", "stalker": result.speed = 1.2
        "poltergeist", "corrosive": result.damage = float(result.damage) * 1.25
        "alpha", "bulwark": result.health = float(result.health) * 1.35
        "replicating": result.health = float(result.health) * 1.15
        "sentinel":
            result.health = float(result.health) * 1.2
            result.damage = float(result.damage) * 1.15
    return result

func to_dict() -> Dictionary:
    return {"monsters": monsters.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    monsters = Dictionary(data.get("monsters", {})).duplicate(true)
