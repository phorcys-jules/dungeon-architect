class_name MonsterProgression
extends RefCounted

const MAX_LEVEL := 10

var monsters: Dictionary = {}

func ensure_monster(monster_id: String, family: String, personality: String = "", seed_value: int = 0) -> void:
    if monsters.has(monster_id):
        return
    var social := MonsterFamilyPersonality.new()
    var generated_traits := social.generate_traits(seed_value if seed_value != 0 else monster_id.hash(), 2)
    if not personality.is_empty():
        generated_traits.erase(personality)
        generated_traits.push_front(personality)
    monsters[monster_id] = {
        "level": 1,
        "experience": 0,
        "family": family,
        "personality": generated_traits[0] if not generated_traits.is_empty() else "cautious",
        "traits": generated_traits,
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
    var traits: Array[String] = []
    for trait_id in entry.get("traits", [entry.get("personality", "cautious")]):
        traits.append(String(trait_id))
    var trait_modifiers := MonsterFamilyPersonality.new().combined_trait_modifiers(traits)
    result.health = float(result.health) * float(trait_modifiers.health)
    result.damage = float(result.damage) * float(trait_modifiers.damage)
    result.speed = float(result.speed) * float(trait_modifiers.speed)
    return result

func to_dict() -> Dictionary:
    return {"monsters": monsters.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    monsters = Dictionary(data.get("monsters", {})).duplicate(true)
    for monster_id in monsters:
        var entry: Dictionary = monsters[monster_id]
        if not entry.has("traits"):
            entry["traits"] = [String(entry.get("personality", "cautious"))]
        monsters[monster_id] = entry
