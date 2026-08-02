extends SceneTree

const Stats := preload("res://scripts/combat/combat_stats.gd")
const Resolver := preload("res://scripts/combat/combat_resolver.gd")

func _init() -> void:
    var attacker := Stats.new()
    attacker.attack = 20.0
    attacker.critical_chance = 0.25
    attacker.critical_multiplier = 2.0
    var defender := Stats.new()
    defender.armor = 5.0
    var resolver := Resolver.new()

    var normal := resolver.resolve_damage(attacker, defender, 0.9)
    if normal.damage != 15.0 or normal.critical:
        quit(1)
        return

    var critical := resolver.resolve_damage(attacker, defender, 0.1)
    if critical.damage != 35.0 or not critical.critical:
        quit(1)
        return

    var slowed := resolver.apply_status(100.0, [{"mode": "multiply", "value": 0.75}, {"mode": "add", "value": -5.0}])
    if not is_equal_approx(slowed, 70.0):
        quit(1)
        return

    print("v0.5 combat resolver test passed")
    quit(0)
