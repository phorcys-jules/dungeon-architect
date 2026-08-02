class_name BossEncounter
extends RefCounted

var boss_id := ""
var definition: Dictionary = {}
var current_health := 0.0
var current_phase := 0
var finished := false

func start(id: String, boss_definition: Dictionary) -> bool:
    if boss_definition.is_empty():
        return false
    boss_id = id
    definition = boss_definition.duplicate(true)
    current_health = float(definition.get("max_health", 1))
    current_phase = 0
    finished = false
    return true

func take_damage(amount: float) -> Dictionary:
    if finished or amount <= 0.0:
        return snapshot()
    current_health = maxf(current_health - amount, 0.0)
    _refresh_phase()
    if current_health <= 0.0:
        finished = true
    return snapshot()

func current_ability() -> String:
    var phases: Array = definition.get("phases", [])
    if phases.is_empty():
        return ""
    return String(phases[current_phase].get("ability", ""))

func damage_output() -> float:
    var phases: Array = definition.get("phases", [])
    var multiplier := 1.0
    if not phases.is_empty():
        multiplier = float(phases[current_phase].get("damage_multiplier", 1.0))
    return float(definition.get("base_damage", 0)) * multiplier

func reward() -> Dictionary:
    return definition.get("reward", {}).duplicate(true) if finished else {}

func introduction() -> Dictionary:
    return {
        "boss_id": boss_id,
        "name": String(definition.get("name", boss_id)),
        "text": String(definition.get("intro", "")),
        "phase_count": Array(definition.get("phases", [])).size(),
    }

func snapshot() -> Dictionary:
    return {
        "boss_id": boss_id,
        "health": current_health,
        "max_health": float(definition.get("max_health", 1)),
        "phase": current_phase,
        "ability": current_ability(),
        "damage": damage_output(),
        "finished": finished,
    }

func _refresh_phase() -> void:
    var phases: Array = definition.get("phases", [])
    if phases.is_empty():
        current_phase = 0
        return
    var ratio := current_health / maxf(float(definition.get("max_health", 1)), 1.0)
    var selected := 0
    for index in phases.size():
        if ratio <= float(phases[index].get("threshold", 1.0)):
            selected = index
    current_phase = selected
