class_name AdventurerIntelligence
extends RefCounted

var encountered: Array[String] = []

func report(adventurer: AdventurerData, laboratory_level: int) -> Dictionary:
    var combat := AdventurerCombatAi.profile(adventurer.id)
    var facts: Array[String] = [
        "%d PV, armure %d" % [adventurer.max_health, adventurer.flat_armor],
        "Vitesse %.2fx" % adventurer.speed_multiplier,
        "Sensibilité pièges %.0f%%" % (adventurer.trap_damage_multiplier * 100.0),
        "Attaque %d, portée %.1f" % [int(combat.damage), float(combat.range_cells)],
        "Comportement : %s" % String(combat.strategy),
    ]
    var visible_count := mini(2 + maxi(laboratory_level, 0), facts.size() - 1)
    return {
        "adventurer_id": adventurer.id,
        "name": adventurer.display_name,
        "visible": facts.slice(0, visible_count),
        "hidden_count": facts.size() - visible_count,
    }

func record_encounter(adventurer_id: String) -> bool:
    if adventurer_id.is_empty() or encountered.has(adventurer_id):
        return false
    encountered.append(adventurer_id)
    return true

func to_dict() -> Dictionary:
    return {"encountered": encountered.duplicate()}

func from_dict(data: Dictionary) -> void:
    encountered.assign(data.get("encountered", []))
