extends SceneTree

func _init() -> void:
    var state := PacmanRoundState.new()
    state.reset(4)
    assert(state.phase == PacmanRoundState.Phase.COLLECTE)
    assert(is_equal_approx(state.tension_speed_multiplier(), 1.0))
    state.update(2, 0.0)
    assert(state.phase == PacmanRoundState.Phase.CHASSE)
    assert(is_equal_approx(state.tension_speed_multiplier(), 1.1))
    state.update(2, 3.5)
    assert(state.phase == PacmanRoundState.Phase.PANIQUE)
    assert(state.label().contains("3.5 s"))
    state.update(0, 0.0)
    assert(state.phase == PacmanRoundState.Phase.RESOLUTION)
    assert(is_equal_approx(state.tension_speed_multiplier(), 1.2))
    print("Pac-Man round state test passed")
    quit(0)
