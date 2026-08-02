extends SceneTree

func _init() -> void:
    var memory := AdventurerRiskMemory.new()
    var danger := Vector2i(2, 3)
    memory.remember_trap(danger, 4.0)
    memory.remember_monster(danger, 2.0)
    if not is_equal_approx(memory.risk_at(danger), 7.5):
        quit(1)
        return
    if not memory.should_replan([Vector2i.ZERO, danger], 6.0):
        quit(1)
        return
    memory.profile = AdventurerRiskMemory.Profile.AGGRESSIVE
    if memory.should_replan([danger], 3.0):
        quit(1)
        return
    memory.forget(danger)
    if memory.risk_at(danger) != 0.0:
        quit(1)
        return
    print("Adventurer risk memory test passed")
    quit(0)
