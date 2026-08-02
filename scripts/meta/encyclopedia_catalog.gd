class_name EncyclopediaCatalog
extends RefCounted

enum DiscoveryState { UNKNOWN, PREVIEWED, DISCOVERED }

var entries := {
    "monster_slime": {"kind": "monster", "name": "Slime", "hint": "Une créature visqueuse."},
    "monster_ghost": {"kind": "monster", "name": "Fantôme", "hint": "Une présence spectrale."},
    "adventurer_thief": {"kind": "adventurer", "name": "Voleur", "hint": "Rapide et opportuniste."},
    "adventurer_mage": {"kind": "adventurer", "name": "Mage", "hint": "Maîtrise les arcanes."},
    "room_treasure": {"kind": "room", "name": "Salle au trésor", "hint": "Attire les plus avides."},
    "synergy_ghost_fog": {"kind": "synergy", "name": "Voile spectral", "hint": "Le brouillard favorise les esprits."},
}

func get_entry(entry_id: String) -> Dictionary:
    if not entries.has(entry_id):
        return {}
    var result: Dictionary = entries[entry_id].duplicate(true)
    result["id"] = entry_id
    return result

func list_by_kind(kind: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for entry_id in entries:
        var entry: Dictionary = entries[entry_id]
        if String(entry.kind) == kind:
            var copy := entry.duplicate(true)
            copy["id"] = entry_id
            result.append(copy)
    return result
