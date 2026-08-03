extends SceneTree

const RuntimeScript := preload("res://scripts/run/tactical_power_runtime.gd")

func _init() -> void:
    var runtime = RuntimeScript.new()
    assert(not bool(runtime.activate("trap_overcharge").ok))
    runtime.gain_from_trap(50)
    runtime.gain_from_combo(40)
    assert(runtime.energy > 0.0 and runtime.energy <= runtime.MAX_ENERGY)
    runtime.energy = 100.0
    assert(bool(runtime.activate("hunt_order").ok))
    assert(not bool(runtime.activate("hunt_order").ok))
    runtime.tick(10.0)
    assert(float(runtime.cooldowns.hunt_order) == 0.0)
    print("tactical power runtime test passed")
    quit(0)
