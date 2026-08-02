class_name AdventurerInventory
extends RefCounted

var capacity := 3
var items: Array[String] = []
var definitions := {
    "key": {"kind": "utility", "priority": 70},
    "potion": {"kind": "healing", "priority": 90},
    "torch": {"kind": "vision", "priority": 60},
    "bomb": {"kind": "combat", "priority": 80},
    "smoke_bomb": {"kind": "escape", "priority": 100},
}

func can_add(item_id: String) -> bool:
    return definitions.has(item_id) and items.size() < capacity

func add(item_id: String) -> bool:
    if not can_add(item_id):
        return false
    items.append(item_id)
    return true

func has(item_id: String) -> bool:
    return items.has(item_id)

func consume(item_id: String) -> bool:
    if not items.has(item_id):
        return false
    items.erase(item_id)
    return true

func best_item_for(context: String, health_ratio: float, fear: float) -> String:
    var candidates: Array[String] = []
    if health_ratio <= 0.45 and has("potion"):
        candidates.append("potion")
    if context == "locked_door" and has("key"):
        candidates.append("key")
    if context == "darkness" and has("torch"):
        candidates.append("torch")
    if context == "combat" and has("bomb"):
        candidates.append("bomb")
    if (context == "escape" or fear >= 75.0) and has("smoke_bomb"):
        candidates.append("smoke_bomb")
    candidates.sort_custom(func(a: String, b: String): return int(definitions[a].priority) > int(definitions[b].priority))
    return candidates[0] if not candidates.is_empty() else ""

func to_dict() -> Dictionary:
    return {"capacity": capacity, "items": items.duplicate()}

func from_dict(data: Dictionary) -> void:
    capacity = maxi(int(data.get("capacity", 3)), 1)
    items.assign(data.get("items", []))
    items = items.filter(func(item_id: String): return definitions.has(item_id)).slice(0, capacity)
