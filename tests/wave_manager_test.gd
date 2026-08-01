extends SceneTree

const WaveManagerScript := preload("res://scripts/core/wave_manager.gd")

func _init() -> void:
    var waves: WaveManager = WaveManagerScript.new()

    assert(waves.is_configuration_valid())
    assert(waves.current_wave == 1)
    assert(waves.get_adventurer_name() == "Éclaireur")
    assert(waves.get_adventurer_description() == "Rapide mais fragile.")
    assert(waves.get_adventurer_health() == 90)
    assert(is_equal_approx(waves.get_speed_multiplier(), 1.18))
    assert(waves.get_wave_reward() == 30)
    assert(is_equal_approx(waves.get_preparation_duration(), 15.0))
    assert(waves.get_label().contains("Éclaireur"))
    assert(waves.get_profile_summary().contains("90 PV"))
    assert(waves.get_profile_summary().contains("1.18x"))
    assert(waves.get_briefing().contains("Rapide mais fragile."))

    assert(waves.advance())
    assert(waves.current_wave == 2)
    assert(waves.get_adventurer_name() == "Guerrier")
    assert(not waves.get_adventurer_color().is_equal_approx(Color.TRANSPARENT))

    while waves.has_next_wave():
        assert(waves.advance())

    assert(waves.current_wave == WaveManager.MAX_WAVES)
    assert(waves.get_adventurer_name() == "Champion")
    assert(waves.get_briefing().contains("Champion"))
    assert(not waves.advance())

    waves.reset()
    assert(waves.current_wave == 1)

    print("WaveManager adventurer profile test passed")
    quit(0)
