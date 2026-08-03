class_name TacticalPowerRuntime
extends RefCounted

const MAX_ENERGY := 100.0
const POWERS := {
    "emergency_lock": {"name": "Verrouillage d'urgence", "cost": 40.0, "cooldown": 12.0, "duration": 4.0, "shortcut": "Q"},
    "hunt_order": {"name": "Ordre de chasse", "cost": 35.0, "cooldown": 10.0, "duration": 5.0, "shortcut": "E"},
    "trap_overcharge": {"name": "Surcharge de piège", "cost": 30.0, "cooldown": 8.0, "duration": 0.0, "shortcut": "F"},
}

var energy := 0.0
var cooldowns: Dictionary = {}

func gain_from_trap(damage: int) -> float:
    energy = minf(MAX_ENERGY, energy + 6.0 + minf(float(maxi(damage, 0)) * 0.08, 8.0))
    return energy

func gain_from_combo(damage: int) -> float:
    energy = minf(MAX_ENERGY, energy + 12.0 + minf(float(maxi(damage, 0)) * 0.1, 8.0))
    return energy

func activate(power_id: String) -> Dictionary:
    if not POWERS.has(power_id):
        return {"ok": false, "reason": "unknown_power"}
    var power: Dictionary = POWERS[power_id]
    if float(cooldowns.get(power_id, 0.0)) > 0.0:
        return {"ok": false, "reason": "cooldown", "remaining": float(cooldowns[power_id])}
    if energy < float(power.cost):
        return {"ok": false, "reason": "energy", "required": float(power.cost)}
    energy -= float(power.cost)
    cooldowns[power_id] = float(power.cooldown)
    return {"ok": true, "id": power_id, "duration": float(power.duration), "cost": float(power.cost)}

func tick(delta: float) -> void:
    for power_id in cooldowns.keys():
        cooldowns[power_id] = maxf(float(cooldowns[power_id]) - maxf(delta, 0.0), 0.0)

func reset() -> void:
    energy = 0.0
    cooldowns.clear()

func blocked_reason(power_id: String) -> String:
    if not POWERS.has(power_id):
        return "Pouvoir inconnu."
    var remaining := float(cooldowns.get(power_id, 0.0))
    if remaining > 0.0:
        return "Recharge : %.1f s." % remaining
    var missing := float(POWERS[power_id].cost) - energy
    if missing > 0.0:
        return "Puissance insuffisante : %.0f manquante." % missing
    return "Disponible."
