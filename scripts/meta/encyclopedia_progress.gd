class_name EncyclopediaProgress
extends RefCounted

var states: Dictionary = {}
var stats: Dictionary = {}

func preview(entry_id: String) -> void:
    var current := int(states.get(entry_id, EncyclopediaCatalog.DiscoveryState.UNKNOWN))
    if current < EncyclopediaCatalog.DiscoveryState.PREVIEWED:
        states[entry_id] = EncyclopediaCatalog.DiscoveryState.PREVIEWED

func discover(entry_id: String) -> bool:
    var was_discovered := int(states.get(entry_id, EncyclopediaCatalog.DiscoveryState.UNKNOWN)) == EncyclopediaCatalog.DiscoveryState.DISCOVERED
    states[entry_id] = EncyclopediaCatalog.DiscoveryState.DISCOVERED
    _ensure_stats(entry_id)
    return not was_discovered

func record_use(entry_id: String, won: bool = false) -> void:
    discover(entry_id)
    _ensure_stats(entry_id)
    stats[entry_id].uses = int(stats[entry_id].uses) + 1
    if won:
        stats[entry_id].wins = int(stats[entry_id].wins) + 1

func state_of(entry_id: String) -> int:
    return int(states.get(entry_id, EncyclopediaCatalog.DiscoveryState.UNKNOWN))

func visible_entry(catalog: EncyclopediaCatalog, entry_id: String) -> Dictionary:
    var entry := catalog.get_entry(entry_id)
    if entry.is_empty():
        return {}
    var state := state_of(entry_id)
    var result := {"id": entry_id, "state": state, "kind": entry.kind}
    if state == EncyclopediaCatalog.DiscoveryState.UNKNOWN:
        result["name"] = "???"
        result["description"] = ""
    elif state == EncyclopediaCatalog.DiscoveryState.PREVIEWED:
        result["name"] = "???"
        result["description"] = String(entry.hint)
    else:
        result["name"] = String(entry.name)
        result["description"] = String(entry.hint)
        result["stats"] = stats.get(entry_id, {"uses": 0, "wins": 0}).duplicate(true)
    return result

func to_dict() -> Dictionary:
    return {"states": states.duplicate(true), "stats": stats.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    states = Dictionary(data.get("states", {})).duplicate(true)
    stats = Dictionary(data.get("stats", {})).duplicate(true)

func _ensure_stats(entry_id: String) -> void:
    if not stats.has(entry_id):
        stats[entry_id] = {"uses": 0, "wins": 0}
