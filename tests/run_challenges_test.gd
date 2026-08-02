extends SceneTree

func _init() -> void:
    var catalog := RunChallengeCatalog.new()
    var first_pick := catalog.pick(42, 3)
    var second_pick := catalog.pick(42, 3)
    assert(first_pick == second_pick)
    assert(first_pick.size() == 3)

    var tracker := RunChallengeTracker.new()
    assert(tracker.start(["no_traps", "pacifist_capture", "single_family"]))
    assert(not tracker.start(["no_traps", "unknown"]))
    assert(tracker.start(["no_traps", "pacifist_capture", "single_family"]))

    tracker.set_metric("traps_placed", 0)
    tracker.set_metric("direct_damage", 0)
    tracker.set_metric("captures", 1)
    tracker.set_metric("monster_families", 1)
    assert(tracker.is_completed("no_traps"))
    assert(tracker.is_completed("pacifist_capture"))
    assert(tracker.is_completed("single_family"))

    var reward := tracker.claim("no_traps", 1.5)
    assert(reward.ok)
    assert(int(reward.gold) == 68)
    assert(int(reward.essence) == 12)
    assert(not tracker.claim("no_traps", 1.5).ok)

    var restored := RunChallengeTracker.new()
    restored.from_dict(tracker.to_dict())
    assert(restored.is_completed("pacifist_capture"))
    assert(restored.claimed.has("no_traps"))
    assert(not restored.progress("single_family").is_empty())

    print("run challenges test passed")
    quit()
