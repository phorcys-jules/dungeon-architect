extends SceneTree

const EvolutionScript := preload("res://scripts/core/defense_evolution.gd")

func _init() -> void:
    var evolution = EvolutionScript.new()
    var cell := Vector2i(2, 3)
    evolution.register(cell, "trap", 30, {"damage": 10, "cooldown": 2.0, "range": 1.0})
    assert(bool(evolution.upgrade(cell, "power", 18).ok))
    assert(int(evolution.evolved_stats(cell).damage) > 10)
    assert(not bool(evolution.upgrade(cell, "tempo", 999).ok))
    assert(bool(evolution.upgrade(cell, "power", 30).ok))
    assert(not bool(evolution.upgrade(cell, "power", 999).ok))
    var recycled := evolution.recycle(cell)
    assert(bool(recycled.ok) and int(recycled.refund) <= int(recycled.invested))
    print("defense evolution test passed")
    quit(0)
