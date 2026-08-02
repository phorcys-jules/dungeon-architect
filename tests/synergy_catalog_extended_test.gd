extends SceneTree

func _init() -> void:
    var catalog := SynergyCatalog.new()
    assert(catalog.all().size() == 10)
    var runtime := SynergyRuntime.new()
    var active := runtime.evaluate(["monster:ghost", "room:fog", "monster:goblin", "building:forge"])
    assert(active.size() == 2)
    assert(runtime.discovered.has("ghost_fog"))
    assert(runtime.discovered.has("goblin_forge"))
    var effects := runtime.combined_effects()
    assert(is_equal_approx(float(effects.evasion), 0.20))
    assert(is_equal_approx(float(effects.monster_damage), 0.15))
    var restored := SynergyRuntime.new()
    restored.from_dict(runtime.to_dict())
    assert(restored.discovered.size() == 2)
    for entry in catalog.all():
        assert(entry.requires.size() >= 2)
        assert(not entry.effect.is_empty())
    print("extended synergy catalog test passed")
    quit()
