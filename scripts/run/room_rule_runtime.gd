class_name RoomRuleRuntime
extends RefCounted

const RULES := {
    &"silence": {"monster_damage_multiplier": 0.8, "power_blocked": true},
    &"darkness": {"adventurer_vision_multiplier": 0.55},
    &"fragile_floor": {"movement_multiplier": 0.75, "collapse_damage": 8},
    &"altar": {"monster_damage_multiplier": 1.2, "objective": &"protect"},
    &"prison": {"adventurer_speed_multiplier": 0.7, "objective": &"capture"},
    &"mana_reserve": {"tactical_energy": 8, "objective": &"harvest"},
}

var room_rules: Dictionary = {}
var objective_results: Dictionary = {}

func assign(cell: Vector2i, rule: StringName) -> bool:
    if not RULES.has(rule):
        return false
    room_rules[cell] = rule
    return true

func effects_at(cell: Vector2i) -> Dictionary:
    var rule: StringName = room_rules.get(cell, &"")
    return RULES.get(rule, {}).duplicate(true)

func complete_objective(cell: Vector2i, success: bool) -> Dictionary:
    var effects := effects_at(cell)
    if not effects.has("objective"):
        return {"ok": false}
    var reward := 20 if success else 0
    objective_results[cell] = {"objective": effects.objective, "success": success, "reward": reward}
    return {"ok": true, "reward": reward, "risk": "room_rule_lost" if not success else "none"}

func is_solvable(entrance: Vector2i, objective: Vector2i, reachable: Array[Vector2i]) -> bool:
    return entrance != objective and reachable.has(entrance) and reachable.has(objective)

func stats() -> Dictionary:
    return {"rules": room_rules.size(), "objectives": objective_results.duplicate(true)}
