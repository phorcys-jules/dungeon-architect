class_name CombatResolver
extends RefCounted

func resolve_damage(attacker: CombatStats, defender: CombatStats, roll: float = 1.0) -> Dictionary:
    var critical := roll <= clampf(attacker.critical_chance, 0.0, 1.0)
    var raw := maxf(attacker.attack, 0.0)
    if critical:
        raw *= maxf(attacker.critical_multiplier, 1.0)
    var mitigation := maxf(defender.armor, 0.0)
    var damage := maxf(raw - mitigation, 1.0)
    return {
        "damage": damage,
        "critical": critical,
        "raw": raw,
        "mitigated": raw - damage
    }

func apply_status(base_value: float, statuses: Array[Dictionary]) -> float:
    var result := base_value
    for status in statuses:
        var mode := String(status.get("mode", "add"))
        var value := float(status.get("value", 0.0))
        if mode == "multiply":
            result *= value
        else:
            result += value
    return maxf(result, 0.0)
