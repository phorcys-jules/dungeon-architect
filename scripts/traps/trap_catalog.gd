class_name TrapCatalog
extends RefCounted

const DEFINITIONS := {
    &"spikes": {"name": "Pointes", "forge_level": 0, "cost": 25, "damage": 35, "cooldown": 1.5, "effect": &"", "duration": 0.0, "strength": 1.0, "color": Color("ed6a5a")},
    &"tar_pit": {"name": "Fosse de poix", "forge_level": 1, "cost": 30, "damage": 10, "cooldown": 2.2, "effect": &"tar_slow", "duration": 3.5, "strength": 0.58, "color": Color("59435f")},
    &"fire_rune": {"name": "Rune incendiaire", "forge_level": 2, "cost": 35, "damage": 30, "cooldown": 0.9, "effect": &"", "duration": 0.0, "strength": 1.0, "color": Color("ff8a3d")},
    &"frost_sigil": {"name": "Sceau de givre", "forge_level": 3, "cost": 32, "damage": 15, "cooldown": 2.8, "effect": &"frost_slow", "duration": 2.4, "strength": 0.35, "color": Color("72d7ff")},
    &"soul_mine": {"name": "Mine d'âme", "forge_level": 4, "cost": 45, "damage": 70, "cooldown": 4.0, "effect": &"", "duration": 0.0, "strength": 1.0, "color": Color("c77dff")},
    &"void_snare": {"name": "Faille du Néant", "forge_level": 5, "cost": 55, "damage": 40, "cooldown": 5.0, "effect": &"void_slow", "duration": 1.2, "strength": 0.15, "color": Color("6d28a8")},
}
const ORDER: Array[StringName] = [&"spikes", &"tar_pit", &"fire_rune", &"frost_sigil", &"soul_mine", &"void_snare"]

static func definition(trap_id: StringName) -> Dictionary:
    var resolved_id := trap_id if DEFINITIONS.has(trap_id) else &"spikes"
    var result := Dictionary(DEFINITIONS[resolved_id]).duplicate(true)
    result["id"] = resolved_id
    return result

static func unlocked_for_forge_level(level: int) -> Array[StringName]:
    var unlocked: Array[StringName] = []
    for trap_id in ORDER:
        if int(DEFINITIONS[trap_id].forge_level) <= level:
            unlocked.append(trap_id)
    return unlocked

static func next_unlock(level: int) -> Dictionary:
    for trap_id in ORDER:
        var value: Dictionary = DEFINITIONS[trap_id]
        if int(value.forge_level) > level:
            return {"id": trap_id, "name": value.name, "level": value.forge_level}
    return {}
