class_name AdventurerRiskMemory
extends RefCounted

enum Profile { CAUTIOUS, AGGRESSIVE, OPPORTUNISTIC }

var profile: Profile = Profile.CAUTIOUS
var trap_risk: Dictionary = {}
var monster_risk: Dictionary = {}

func remember_trap(cell: Vector2i, severity: float) -> void:
    trap_risk[cell] = maxf(float(trap_risk.get(cell, 0.0)), maxf(severity, 0.0))

func remember_monster(cell: Vector2i, threat: float) -> void:
    monster_risk[cell] = maxf(float(monster_risk.get(cell, 0.0)), maxf(threat, 0.0))

func forget(cell: Vector2i) -> void:
    trap_risk.erase(cell)
    monster_risk.erase(cell)

func risk_at(cell: Vector2i) -> float:
    var raw := float(trap_risk.get(cell, 0.0)) + float(monster_risk.get(cell, 0.0))
    match profile:
        Profile.AGGRESSIVE:
            return raw * 0.45
        Profile.OPPORTUNISTIC:
            return raw * 0.75
        _:
            return raw * 1.25

func build_risk_map(cells: Array[Vector2i]) -> Dictionary:
    var result := {}
    for cell in cells:
        var value := risk_at(cell)
        if value > 0.0:
            result[cell] = value
    return result

func should_replan(next_path: Array[Vector2i], threshold: float) -> bool:
    for cell in next_path:
        if risk_at(cell) >= threshold:
            return true
    return false
