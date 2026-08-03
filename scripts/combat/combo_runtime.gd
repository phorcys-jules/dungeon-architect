class_name ComboRuntime
extends RefCounted

const COMBOS: Array[Dictionary] = [
    {"id": "brittle_slime", "name": "Gelée cassante", "requires": ["slimed", "frozen"], "damage": 18, "result": "vulnerable"},
    {"id": "inferno_tar", "name": "Brasier de poix", "requires": ["tarred", "burning"], "damage": 28, "result": "frightened"},
    {"id": "impaled_web", "name": "Toile empalée", "requires": ["webbed", "vulnerable"], "damage": 22, "result": "immobilized"},
    {"id": "terror_ambush", "name": "Embuscade terrifiante", "requires": ["frightened", "ambushed"], "damage": 26, "result": "vulnerable"},
    {"id": "spectral_curse", "name": "Drain spectral", "requires": ["cursed", "spectral"], "damage": 24, "result": "frightened"},
    {"id": "frozen_sewer", "name": "Déluge gelé", "requires": ["wet", "frozen"], "damage": 16, "result": "immobilized"},
]

var states: Array[String] = []
var trigger_counts: Dictionary = {}

func apply_state(state_id: String) -> Dictionary:
    if state_id.is_empty():
        return {}
    if not states.has(state_id):
        states.append(state_id)
    for combo in COMBOS:
        if _has_all(combo.requires):
            for required_state in combo.requires:
                states.erase(String(required_state))
            var combo_id := String(combo.id)
            trigger_counts[combo_id] = int(trigger_counts.get(combo_id, 0)) + 1
            return combo.duplicate(true)
    return {}

func clear() -> void:
    states.clear()

func total_triggers() -> int:
    var result := 0
    for count in trigger_counts.values():
        result += int(count)
    return result

func _has_all(required_states: Array) -> bool:
    for state_id in required_states:
        if not states.has(String(state_id)):
            return false
    return true
