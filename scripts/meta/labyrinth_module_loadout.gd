class_name LabyrinthModuleLoadout
extends RefCounted

const MAX_COMPLEXITY := 5
const DEFINITIONS := {
    "corridor_network": {"name": "Réseau de couloirs", "cost": 1, "building": "", "level": 0, "density": -0.05, "loops": 0, "gates": 0},
    "crossroad_core": {"name": "Noyau de carrefours", "cost": 2, "building": "forge", "level": 1, "density": 0.0, "loops": 4, "gates": 0},
    "loop_network": {"name": "Boucles renforcées", "cost": 2, "building": "laboratory", "level": 1, "density": -0.02, "loops": 3, "gates": 1},
    "route_gates": {"name": "Portes de détour", "cost": 2, "building": "graveyard", "level": 1, "density": 0.02, "loops": 1, "gates": 2},
}

var selected: Array[String] = ["corridor_network"]

func unlocked_ids(building_levels: Dictionary) -> Array[String]:
    var result: Array[String] = []
    for module_id in DEFINITIONS:
        var definition: Dictionary = DEFINITIONS[module_id]
        var building := String(definition.building)
        if building.is_empty() or int(building_levels.get(building, 0)) >= int(definition.level):
            result.append(String(module_id))
    return result

func select(module_ids: Array[String], building_levels: Dictionary) -> Dictionary:
    var available := unlocked_ids(building_levels)
    var validated: Array[String] = []
    var complexity := 0
    for module_id in module_ids:
        if not available.has(module_id):
            return {"ok": false, "reason": "module_locked", "module_id": module_id}
        if validated.has(module_id):
            continue
        complexity += int(DEFINITIONS[module_id].cost)
        if complexity > MAX_COMPLEXITY:
            return {"ok": false, "reason": "complexity_budget", "module_id": module_id}
        validated.append(module_id)
    if validated.is_empty():
        return {"ok": false, "reason": "empty_loadout"}
    selected = validated
    return {"ok": true, "complexity": complexity}

func complexity_used() -> int:
    var total := 0
    for module_id in selected:
        if DEFINITIONS.has(module_id):
            total += int(DEFINITIONS[module_id].cost)
    return total

func generator_modifiers() -> Dictionary:
    var result := {"density": 0.0, "loops": 0, "gates": 0}
    for module_id in selected:
        if not DEFINITIONS.has(module_id):
            continue
        var definition: Dictionary = DEFINITIONS[module_id]
        result.density = float(result.density) + float(definition.density)
        result.loops = int(result.loops) + int(definition.loops)
        result.gates = int(result.gates) + int(definition.gates)
    return result

func to_dict() -> Dictionary:
    return {"selected": selected.duplicate()}

func from_dict(data: Dictionary, building_levels: Dictionary) -> void:
    var saved: Array[String] = []
    saved.assign(data.get("selected", ["corridor_network"]))
    if not bool(select(saved, building_levels).ok):
        selected = ["corridor_network"]
