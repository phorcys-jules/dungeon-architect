extends SceneTree

const RunStatsScript := preload("res://scripts/core/run_stats.gd")

func _init() -> void:
    var stats: RunStats = RunStatsScript.new()
    stats.tick(1.25)
    stats.record_trap(25)
    stats.record_defender_attack(12)
    stats.finish("VICTOIRE")
    stats.finish("DÉFAITE")

    assert(is_equal_approx(stats.elapsed_time, 1.25))
    assert(stats.total_damage == 37)
    assert(stats.traps_triggered == 1)
    assert(stats.defender_attacks == 1)
    assert(stats.result == "VICTOIRE")
    assert(stats.is_finished())
    assert(stats.summary().contains("37"))

    stats.reset()
    assert(stats.elapsed_time == 0.0)
    assert(stats.total_damage == 0)
    assert(not stats.is_finished())
    print("RunStats test passed")
    quit(0)
