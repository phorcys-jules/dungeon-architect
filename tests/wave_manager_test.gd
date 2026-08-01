extends SceneTree

const WaveManagerScript := preload("res://scripts/core/wave_manager.gd")

func _init() -> void:
    var waves: WaveManager = WaveManagerScript.new()

    assert(waves.current_wave == 1)
    assert(waves.get_adventurer_health() == 100)
    assert(is_equal_approx(waves.get_speed_multiplier(), 1.0))
    assert(waves.get_wave_reward() == 30)
    assert(waves.get_label() == "Vague 1 / 5")

    assert(waves.advance())
    assert(waves.current_wave == 2)
    assert(waves.get_adventurer_health() == 125)
    assert(is_equal_approx(waves.get_speed_multiplier(), 1.08))

    while waves.has_next_wave():
        assert(waves.advance())

    assert(waves.current_wave == 5)
    assert(not waves.advance())
    assert(waves.get_adventurer_health() == 200)

    waves.reset()
    assert(waves.current_wave == 1)

    print("WaveManager test passed")
    quit(0)
