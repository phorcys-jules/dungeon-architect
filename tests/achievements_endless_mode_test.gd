extends SceneTree

func _init() -> void:
    var achievements := AchievementTracker.new()
    assert(achievements.add_progress("captures", 1) == ["first_capture"])
    assert(achievements.is_unlocked("first_capture"))
    assert(achievements.consume_notifications() == ["first_capture"])
    achievements.add_progress("endless_wave", 9)
    assert(not achievements.is_unlocked("endless_ten"))
    assert(achievements.add_progress("endless_wave", 1) == ["endless_ten"])

    var restored_achievements := AchievementTracker.new()
    restored_achievements.from_dict(achievements.to_dict())
    assert(restored_achievements.is_unlocked("first_capture"))
    assert(restored_achievements.is_unlocked("endless_ten"))

    var endless := EndlessModeDirector.new()
    endless.start(1234, 500)
    for index in 5:
        var wave_data := endless.next_wave()
        assert(int(wave_data.wave) == index + 1)
    assert(endless.active_modifiers.size() == 1)
    var gained := endless.complete_wave(2, 80, 20.0)
    assert(gained > 0)
    assert(endless.best_score >= 500)
    assert(endless.share_seed() == "DA-ENDLESS-1234")

    var second := EndlessModeDirector.new()
    second.start(1234)
    for index in 5:
        second.next_wave()
    assert(second.active_modifiers == endless.active_modifiers)

    var restored_endless := EndlessModeDirector.new()
    restored_endless.from_dict(endless.to_dict())
    assert(restored_endless.wave == 5)
    assert(restored_endless.score == endless.score)

    print("achievements and endless mode test passed")
    quit()
