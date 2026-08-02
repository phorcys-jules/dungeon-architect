extends SceneTree

func _init() -> void:
    var director := RunEventDirector.new()
    var first := director.roll(42, 3, "crypt")
    assert(not first.is_empty())
    var restored := RunEventDirector.new()
    restored.from_dict(director.to_dict())
    assert(restored.history == director.history)
    assert(restored.active_events.size() == 1)

    var same := RunEventDirector.new()
    var same_first := same.roll(42, 3, "crypt")
    assert(String(same_first.id) == String(first.id))

    var effects := director.combined_effects()
    assert(not effects.is_empty())
    var announcement := director.announcement(first)
    assert(not String(announcement.title).is_empty())
    assert(int(announcement.duration) > 0)

    var duration := int(first.remaining)
    var expired: Array[String] = []
    for _index in duration:
        expired = director.tick_stage()
    assert(expired.has(String(first.id)))
    assert(director.active_events.is_empty())

    var catalog := RunEventCatalog.new()
    var eligible := catalog.eligible(3, "crypt", ["total_darkness"])
    assert(not eligible.has("royal_visit"))
    assert(not eligible.has("torch_bearers"))
    assert(not catalog.eligible(1, "crypt", []).has("royal_visit"))

    print("run events test passed")
    quit()
