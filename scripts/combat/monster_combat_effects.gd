class_name MonsterCombatEffects
extends RefCounted

const EFFECTS := {
    "ghost": {"effect": "phase_strike", "damage": 16.0, "status": "fear", "duration": 1.5},
    "slime": {"effect": "slowing_splash", "damage": 8.0, "status": "slow", "duration": 3.0},
    "mimic": {"effect": "ambush_bite", "damage": 24.0, "status": "stagger", "duration": 1.0},
    "spider": {"effect": "web_shot", "damage": 6.0, "status": "root", "duration": 2.0},
}

func resolve(monster_id: String, synergy_modifiers: Dictionary = {}) -> Dictionary:
    var result: Dictionary = EFFECTS.get(monster_id, {}).duplicate(true)
    if result.is_empty():
        return {"success": false}
    var multiplier := float(synergy_modifiers.get("damage_multiplier", 1.0))
    result.damage = float(result.damage) * multiplier
    result.duration = float(result.duration) + float(synergy_modifiers.get("duration_bonus", 0.0))
    result.success = true
    return result

func feedback(event: Dictionary) -> Dictionary:
    return {
        "label": String(event.get("effect", "impact")),
        "damage": float(event.get("damage", 0.0)),
        "critical": bool(event.get("critical", false)),
        "status": String(event.get("status", "")),
        "duration": float(event.get("duration", 0.0)),
    }
