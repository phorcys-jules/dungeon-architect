extends SceneTree

func _init() -> void:
    var effects := MonsterCombatEffects.new()
    var ghost := effects.resolve("ghost", {"damage_multiplier": 1.5})
    if not ghost.success or not is_equal_approx(float(ghost.damage), 24.0):
        quit(1)
        return
    var slime := effects.resolve("slime", {"duration_bonus": 1.0})
    if slime.status != "slow" or not is_equal_approx(float(slime.duration), 4.0):
        quit(1)
        return
    var unknown := effects.resolve("unknown")
    if unknown.success:
        quit(1)
        return
    var feedback := effects.feedback(ghost)
    if feedback.label != "phase_strike" or feedback.status != "fear":
        quit(1)
        return
    print("Monster combat effects test passed")
    quit(0)
