class_name AdventurerAbilityCatalog
extends RefCounted

const ABILITIES := {
    "thief": {"id": "disarm", "cooldown": 4.0, "range": 1.0, "effect": "disable_trap", "power": 1.0},
    "mage": {"id": "arcane_bolt", "cooldown": 3.0, "range": 5.0, "effect": "damage_obstacle", "power": 18.0},
    "priest": {"id": "healing_prayer", "cooldown": 6.0, "range": 3.0, "effect": "heal_ally", "power": 22.0},
    "berserker": {"id": "charge", "cooldown": 5.0, "range": 4.0, "effect": "break_door", "power": 26.0},
    "ranger": {"id": "piercing_shot", "cooldown": 4.0, "range": 6.0, "effect": "ranged_damage", "power": 20.0},
    "paladin": {"id": "shield_bash", "cooldown": 5.0, "range": 1.0, "effect": "stun", "power": 14.0},
}

func get_ability(profile_id: String) -> Dictionary:
    return ABILITIES.get(profile_id, {}).duplicate(true)

func get_profiles() -> Array[String]:
    var profiles: Array[String] = []
    for profile_id in ABILITIES.keys():
        profiles.append(String(profile_id))
    profiles.sort()
    return profiles
