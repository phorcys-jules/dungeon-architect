extends SceneTree

const WaveManagerScript := preload("res://scripts/core/wave_manager.gd")

func _init() -> void:
    var waves: WaveManager = WaveManagerScript.new()

    assert(waves.is_configuration_valid())
    assert(waves.current_wave == 1)
    assert(waves.get_adventurer_name() == "Éclaireur")
    assert(waves.get_adventurer_health() == 90)
    assert(is_equal_approx(waves.get_speed_multiplier(), 1.18))
    assert(waves.get_wave_reward() == 30)
    assert(is_equal_approx(waves.get_preparation_duration(), 15.0))
    assert(waves.get_label().contains("Éclaireur"))

    assert(waves.advance())
    assert(waves.current_wave == 2)
    assert(waves.get_adventurer_name() == "Guerrier")

    while waves.has_next_wave():
        assert(waves.advance())

    assert(waves.current_wave == WaveManager.MAX_WAVES)
    assert(waves.get_adventurer_name() == "Champion")
    assert(not waves.advance())

    waves.reset()
    assert(waves.current_wave == 1)

    print("WaveManager data-driven test passed")
    quit(0)
