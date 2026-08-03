class_name RoomDeckSelection
extends RefCounted

const MAX_ROOMS := 5
const DEFAULT_IDS: Array[String] = ["cursed_shrine", "fog_chamber", "slime_pool", "crossroads", "monster_portal"]
const ROOM_PATHS := {
    "corridor": "res://resources/rooms/corridor.tres",
    "crossroads": "res://resources/rooms/crossroads.tres",
    "fog_chamber": "res://resources/rooms/fog_chamber.tres",
    "slime_pool": "res://resources/rooms/slime_pool.tres",
    "false_treasure": "res://resources/rooms/false_treasure.tres",
    "monster_portal": "res://resources/rooms/monster_portal.tres",
    "ice_gallery": "res://resources/rooms/ice_gallery.tres",
    "cursed_shrine": "res://resources/rooms/cursed_shrine.tres",
    "treasure_hall": "res://resources/rooms/treasure_hall.tres",
}

var selected: Array[String] = DEFAULT_IDS.duplicate()
var biome_id := BiomeCatalog.CRYPT

func room_ids() -> Array[String]:
    var ids: Array[String] = []
    ids.assign(ROOM_PATHS.keys())
    ids.sort()
    return ids

func room(room_id: String) -> RoomData:
    if not ROOM_PATHS.has(room_id):
        return null
    return load(String(ROOM_PATHS[room_id])) as RoomData

func selected_tags() -> Array[StringName]:
    var tags: Array[StringName] = []
    for room_id in selected:
        var definition := room(room_id)
        if definition == null:
            continue
        for tag: StringName in definition.tags:
            if not tags.has(tag):
                tags.append(tag)
    return tags

func select(room_ids: Array[String]) -> Dictionary:
    if room_ids.is_empty():
        return {"ok": false, "reason": "empty_deck"}
    if room_ids.size() > MAX_ROOMS:
        return {"ok": false, "reason": "too_many_rooms"}
    var counts: Dictionary = {}
    for room_id in room_ids:
        var definition := room(room_id)
        if definition == null:
            return {"ok": false, "reason": "unknown_room", "room_id": room_id}
        counts[room_id] = int(counts.get(room_id, 0)) + 1
        if int(counts[room_id]) > definition.max_copies:
            return {"ok": false, "reason": "copy_limit", "room_id": room_id}
    selected = room_ids.duplicate()
    return {"ok": true}

func set_biome(candidate_id: String) -> Dictionary:
    if BiomeCatalog.new().get_biome(candidate_id).is_empty():
        return {"ok": false, "reason": "unknown_biome"}
    biome_id = candidate_id
    return {"ok": true}

func validate_for_biome(candidate_biome_id: String = biome_id) -> Dictionary:
    return _validate_biome(selected, candidate_biome_id)

func _validate_biome(room_ids: Array[String], candidate_biome_id: String) -> Dictionary:
    var catalog := BiomeCatalog.new()
    var all_tags: Array[String] = []
    for room_id in room_ids:
        var definition := room(room_id)
        if definition == null:
            continue
        var room_tags: Array[String] = []
        for tag in definition.tags:
            var text := String(tag)
            room_tags.append(text)
            if not all_tags.has(text):
                all_tags.append(text)
        var allowed := catalog.validate_room_tags(candidate_biome_id, room_tags)
        if not bool(allowed.ok):
            return allowed
    if not catalog.has_required_room(candidate_biome_id, all_tags):
        var biome := catalog.get_biome(candidate_biome_id)
        return {"ok": false, "reason": "missing_required_tag", "tag": biome.construction.required_room_tags[0]}
    return {"ok": true}

func rejection_message(result: Dictionary) -> String:
    match String(result.get("reason", "")):
        "empty_deck": return "Le deck doit contenir au moins une pièce."
        "too_many_rooms": return "Le deck est limité à %d pièces." % MAX_ROOMS
        "unknown_room": return "Cette pièce est inconnue."
        "copy_limit": return "Nombre maximal de copies atteint pour cette pièce."
        "blocked_tag": return "Ce biome interdit le tag « %s »." % String(result.get("tag", "?"))
        "missing_required_tag": return "Ce biome exige une pièce avec le tag « %s »." % String(result.get("tag", "?"))
        "unknown_biome": return "Ce biome est inconnu."
    return "Le deck n'est pas valide."

func add(room_id: String) -> Dictionary:
    var candidate: Array[String] = selected.duplicate()
    candidate.append(room_id)
    return select(candidate)

func remove_last() -> Dictionary:
    if selected.size() <= 1:
        return {"ok": false, "reason": "empty_deck"}
    var candidate: Array[String] = selected.duplicate()
    candidate.pop_back()
    return select(candidate)

func display_summary() -> String:
    var names: Array[String] = []
    for room_id in selected:
        var definition := room(room_id)
        names.append(definition.display_name if definition != null else room_id)
    return " · ".join(names)

func to_dict() -> Dictionary:
    return {"selected": selected.duplicate(), "biome_id": biome_id}

func from_dict(data: Dictionary) -> void:
    var saved_biome := String(data.get("biome_id", BiomeCatalog.CRYPT))
    biome_id = saved_biome if not BiomeCatalog.new().get_biome(saved_biome).is_empty() else BiomeCatalog.CRYPT
    var saved: Array[String] = []
    saved.assign(data.get("selected", DEFAULT_IDS))
    if not bool(select(saved).ok):
        selected = DEFAULT_IDS.duplicate()
