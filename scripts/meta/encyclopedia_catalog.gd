class_name EncyclopediaCatalog
extends RefCounted

enum DiscoveryState { UNKNOWN, PREVIEWED, DISCOVERED }

var entries := {
    "monster_slime": {"kind": "monster", "name": "Slime", "hint": "Une créature visqueuse."},
    "monster_ghost": {"kind": "monster", "name": "Fantôme", "hint": "Une présence spectrale."},
    "adventurer_thief": {"kind": "adventurer", "name": "Voleur", "hint": "Rapide et opportuniste."},
    "adventurer_mage": {"kind": "adventurer", "name": "Mage", "hint": "Maîtrise les arcanes."},
    "adventurer_priest": {"kind": "adventurer", "name": "Prêtre", "hint": "Purifie les pièges et protège son groupe."},
    "adventurer_berserker": {"kind": "adventurer", "name": "Berserker", "hint": "Devient plus dangereux quand il est blessé."},
    "room_treasure": {"kind": "room", "name": "Salle au trésor", "hint": "Attire les plus avides."},
    "synergy_ghost_fog": {"kind": "synergy", "name": "Voile spectral", "hint": "Le brouillard favorise les esprits."},
    "monster_mimic": {"kind": "monster", "name": "Mimic", "hint": "Un coffre qui mord."},
    "monster_spider": {"kind": "monster", "name": "Araignée", "hint": "Elle contrôle les carrefours."},
    "adventurer_scout": {"kind": "adventurer", "name": "Éclaireur", "hint": "Rapide et fragile."},
    "adventurer_warrior": {"kind": "adventurer", "name": "Guerrier", "hint": "Solide et équilibré."},
    "adventurer_champion": {"kind": "adventurer", "name": "Champion", "hint": "Lent et lourdement blindé."},
    "room_fog": {"kind": "room", "name": "Brume", "hint": "Dissimule les esprits."},
    "room_ice": {"kind": "room", "name": "Glace", "hint": "Un sol difficile à franchir."},
    "room_fog_chamber": {"kind": "room", "name": "Salle de brume", "hint": "Une pièce noyée dans le brouillard."},
    "room_slime_pool": {"kind": "room", "name": "Bassin de slime", "hint": "Une mare collante."},
    "room_false_treasure": {"kind": "room", "name": "Faux trésor", "hint": "Un appât suspect."},
    "room_monster_portal": {"kind": "room", "name": "Portail", "hint": "Un raccourci pour les monstres."},
    "room_corridor": {"kind": "room", "name": "Couloir", "hint": "Un passage simple propice aux embuscades."},
    "room_crossroads": {"kind": "room", "name": "Carrefour", "hint": "Quatre routes et autant de décisions."},
    "room_ice_gallery": {"kind": "room", "name": "Galerie de glace", "hint": "Un sol glissant difficile à franchir."},
    "room_cursed_shrine": {"kind": "room", "name": "Sanctuaire maudit", "hint": "Un pouvoir puissant assorti d'un risque."},
    "room_treasure_hall": {"kind": "room", "name": "Salle au trésor", "hint": "Un appât irrésistible pour les aventuriers."},
    "synergy_slime_ice": {"kind": "synergy", "name": "Gel visqueux", "hint": "Le froid transforme le slime en piège durable."},
    "synergy_mimic_treasure": {"kind": "synergy", "name": "Trésor piégé", "hint": "Les richesses rendent le mimic plus dangereux."},
    "biome_crypt": {"kind": "biome", "name": "Crypte", "hint": "Les morts y sont chez eux."},
    "biome_mine": {"kind": "biome", "name": "Mine", "hint": "Des galeries étroites."},
    "biome_castle": {"kind": "biome", "name": "Château", "hint": "Une forteresse abandonnée."},
    "biome_sewers": {"kind": "biome", "name": "Égouts", "hint": "Humides et toxiques."},
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
    result.sort_custom(func(a: Dictionary, b: Dictionary): return String(a.id) < String(b.id))
    return result
