class_name V04ProgressionService
extends RefCounted

var catalog := V04ContentCatalog.new()
var state: Dictionary

func _init(initial_state: Dictionary = {}) -> void:
    state = catalog.migrate_save(initial_state)

func buy_building_level(building_id: StringName, available_resources: int) -> Dictionary:
    for building: VillageBuildingData in catalog.buildings():
        if building.building_id != building_id:
            continue
        var levels: Dictionary = state["buildings"]
        var current := int(levels.get(String(building_id), 0))
        if current >= building.max_level:
            return {"success": false, "remaining": available_resources}
        var cost := building.cost_for_level(current + 1)
        if available_resources < cost:
            return {"success": false, "remaining": available_resources}
        levels[String(building_id)] = current + 1
        return {"success": true, "remaining": available_resources - cost, "level": current + 1}
    return {"success": false, "remaining": available_resources}

func buy_upgrade(upgrade_id: StringName, available_resources: int) -> Dictionary:
    var definitions := catalog.permanent_upgrades()
    if not definitions.has(upgrade_id):
        return {"success": false, "remaining": available_resources}
    var purchased: Dictionary = state["permanent_upgrades"]
    if purchased.has(String(upgrade_id)):
        return {"success": false, "remaining": available_resources}
    var cost := int(definitions[upgrade_id]["cost"])
    if available_resources < cost:
        return {"success": false, "remaining": available_resources}
    purchased[String(upgrade_id)] = true
    return {"success": true, "remaining": available_resources - cost}

func combined_modifiers() -> Dictionary:
    var result: Dictionary = {}
    var levels: Dictionary = state["buildings"]
    for building: VillageBuildingData in catalog.buildings():
        var level := int(levels.get(String(building.building_id), 0))
        result[building.bonus_key] = float(result.get(building.bonus_key, 0.0)) + building.bonus_per_level * level
    var purchased: Dictionary = state["permanent_upgrades"]
    for id: Variant in purchased.keys():
        var key := StringName(id)
        var definition: Dictionary = catalog.permanent_upgrades().get(key, {})
        if not definition.is_empty():
            var modifier: StringName = definition["modifier"]
            result[modifier] = float(result.get(modifier, 0.0)) + float(definition["value"])
    return result
