class_name MonsterProgression
extends RefCounted

const LEVEL_XP := [0, 50, 140, 280, 480]

var monster_id := ""
var family := ""
var level := 1
var experience := 0
var evolution := ""

func setup(id: String, monster_family: String) -> void:
    monster_id = id
    family = monster_family
    level = 1
    experience = 0
    evolution = ""

func grant_experience(amount: int) -> int:
    experience += maxi(amount, 0)
    while level < LEVEL_XP.size() and experience >= LEVEL_XP[level]:
        level += 1
    return level

func available_evolutions() -> Array[String]:
    if level < 3 or not evolution.is_empty():
        return []
    match family:
        "spectral": return ["wraith", "poltergeist"]
        "slime": return ["acid_slime", "frost_slime"]
        "beast": return ["broodmother", "venom_stalker"]
        _: return ["guardian", "hunter"]

func choose_evolution(value: String) -> bool:
    if not evolution.is_empty() or not available_evolutions().has(value):
        return false
    evolution = value
    return true

func stat_modifiers() -> Dictionary:
    var result := {
        "health_multiplier": 1.0 + float(level - 1) * 0.08,
        "damage_multiplier": 1.0 + float(level - 1) * 0.06,
        "speed_multiplier": 1.0,
    }
    match evolution:
        "wraith", "venom_stalker", "hunter": result.speed_multiplier = 1.15
        "poltergeist", "acid_slime": result.damage_multiplier = float(result.damage_multiplier) + 0.2
        "frost_slime", "broodmother", "guardian": result.health_multiplier = float(result.health_multiplier) + 0.25
    return result

func to_dict() -> Dictionary:
    return {"monster_id": monster_id, "family": family, "level": level, "experience": experience, "evolution": evolution}

func from_dict(data: Dictionary) -> void:
    monster_id = str(data.get("monster_id", ""))
    family = str(data.get("family", ""))
    level = clampi(int(data.get("level", 1)), 1, LEVEL_XP.size())
    experience = maxi(int(data.get("experience", 0)), 0)
    evolution = str(data.get("evolution", ""))
