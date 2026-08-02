class_name RelicCatalog
extends RefCounted

var definitions := {
    "blood_crown": {"name": "Couronne de sang", "tags": ["monster"], "effects": {"monster_damage_multiplier": 1.15}},
    "echoing_key": {"name": "Clé des échos", "tags": ["door"], "effects": {"door_cooldown_multiplier": 0.7}},
    "greedy_idol": {"name": "Idole avide", "tags": ["economy"], "effects": {"reward_multiplier": 1.2}},
    "thorn_heart": {"name": "Cœur d'épines", "tags": ["trap"], "effects": {"trap_damage_multiplier": 1.25}},
    "mist_lantern": {"name": "Lanterne de brume", "tags": ["room", "ghost"], "effects": {"panic_duration_bonus": 2.0}},
}

var owned: Array[String] = []
var equipped: Array[String] = []
var equip_limit := 2

func grant(relic_id: String) -> bool:
    if not definitions.has(relic_id) or owned.has(relic_id):
        return false
    owned.append(relic_id)
    return true

func equip(relic_ids: Array[String]) -> bool:
    if relic_ids.size() > equip_limit:
        return false
    var unique: Array[String] = []
    for relic_id in relic_ids:
        if not owned.has(relic_id) or unique.has(relic_id):
            return false
        unique.append(relic_id)
    equipped = unique
    return true

func combined_effects() -> Dictionary:
    var result := {}
    for relic_id in equipped:
        var effects: Dictionary = definitions[relic_id].effects
        for key in effects:
            var value = effects[key]
            if value is float or value is int:
                if String(key).ends_with("_multiplier"):
                    result[key] = float(result.get(key, 1.0)) * float(value)
                else:
                    result[key] = float(result.get(key, 0.0)) + float(value)
    return result

func active_labels() -> Array[String]:
    var result: Array[String] = []
    for relic_id in equipped:
        result.append(String(definitions[relic_id].name))
    return result

func to_dict() -> Dictionary:
    return {"owned": owned.duplicate(), "equipped": equipped.duplicate()}

func from_dict(data: Dictionary) -> void:
    owned.assign(data.get("owned", []))
    owned = owned.filter(func(id: String): return definitions.has(id))
    equipped.assign(data.get("equipped", []))
    equipped = equipped.filter(func(id: String): return owned.has(id)).slice(0, equip_limit)
