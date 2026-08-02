extends SceneTree

const WaveManagerScript := preload("res://scripts/core/wave_manager.gd")

func _check(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error("WaveManager test failed: %s" % message)
    quit(1)
    return false

func _init() -> void:
    var waves: WaveManager = WaveManagerScript.new()

    if not _check(waves.is_configuration_valid(), "invalid wave configuration"):
        return
    if not _check(waves.current_wave == 1, "campaign must start at wave 1"):
        return
    if not _check(waves.get_adventurer_name() == "Éclaireur", "wave 1 profile mismatch"):
        return
    if not _check(waves.get_adventurer_description().contains("Rapide mais fragile"), "scout description mismatch"):
        return
    if not _check(waves.get_adventurer_health() == 90, "scout health mismatch"):
        return
    if not _check(is_equal_approx(waves.get_speed_multiplier(), 1.18), "scout speed mismatch"):
        return
    if not _check(waves.get_wave_reward() == 30, "wave 1 reward mismatch"):
        return
    if not _check(is_equal_approx(waves.get_preparation_duration(), 15.0), "wave 1 preparation mismatch"):
        return
    if not _check(waves.get_label().contains("Éclaireur"), "wave label missing profile"):
        return
    if not _check(waves.get_profile_summary().contains("90 PV"), "summary missing health"):
        return
    if not _check(waves.get_profile_summary().contains("1.18x"), "summary missing speed"):
        return
    if not _check(waves.get_briefing().contains("Rapide mais fragile"), "briefing missing description"):
        return

    if not _check(waves.advance(), "cannot advance to wave 2"):
        return
    if not _check(waves.current_wave == 2, "wave index did not advance"):
        return
    if not _check(waves.get_adventurer_name() == "Guerrier", "wave 2 profile mismatch"):
        return
    if not _check(not waves.get_adventurer_color().is_equal_approx(Color.TRANSPARENT), "profile color is transparent"):
        return

    var safety := 0
    while waves.has_next_wave() and safety < WaveManager.MAX_WAVES:
        if not _check(waves.advance(), "advance failed before final wave"):
            return
        safety += 1

    if not _check(safety < WaveManager.MAX_WAVES, "wave progression loop did not terminate"):
        return
    if not _check(waves.current_wave == WaveManager.MAX_WAVES, "final wave index mismatch"):
        return
    if not _check(waves.get_adventurer_name() == "Champion", "final profile mismatch"):
        return
    if not _check(waves.get_briefing().contains("Champion"), "final briefing mismatch"):
        return
    if not _check(not waves.advance(), "advanced beyond final wave"):
        return

    waves.reset()
    if not _check(waves.current_wave == 1, "reset did not restore wave 1"):
        return

    print("WaveManager adventurer profile test passed")
    quit(0)
