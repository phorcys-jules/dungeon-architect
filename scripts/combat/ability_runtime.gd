class_name AbilityRuntime
extends RefCounted

var cooldowns: Dictionary = {}

func can_use(actor_id: String, ability: Dictionary) -> bool:
    return float(cooldowns.get(actor_id, 0.0)) <= 0.0 and not ability.is_empty()

func use(actor_id: String, ability: Dictionary) -> Dictionary:
    if not can_use(actor_id, ability):
        return {"success": false, "effect": "", "power": 0.0}
    cooldowns[actor_id] = maxf(float(ability.get("cooldown", 0.0)), 0.0)
    return {
        "success": true,
        "effect": String(ability.get("effect", "")),
        "power": float(ability.get("power", 0.0)),
        "range": float(ability.get("range", 0.0)),
    }

func tick(delta: float) -> void:
    for actor_id in cooldowns.keys():
        cooldowns[actor_id] = maxf(float(cooldowns[actor_id]) - delta, 0.0)

func remaining(actor_id: String) -> float:
    return float(cooldowns.get(actor_id, 0.0))
