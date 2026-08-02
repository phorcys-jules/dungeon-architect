extends SceneTree

func _init() -> void:
    var forge_level_cap := 0
    for building in V04ContentCatalog.new().buildings():
        if building.building_id == &"forge":
            forge_level_cap = building.max_level
    assert(forge_level_cap == 5)
    assert(TrapCatalog.unlocked_for_forge_level(0) == [&"spikes"])
    assert(TrapCatalog.unlocked_for_forge_level(1) == [&"spikes", &"tar_pit"])
    assert(TrapCatalog.unlocked_for_forge_level(4).size() == 5)
    assert(String(TrapCatalog.next_unlock(1).name) == "Rune incendiaire")
    assert(String(TrapCatalog.next_unlock(4).name) == "Faille du Néant")
    assert(TrapCatalog.unlocked_for_forge_level(5).size() == 6)
    assert(TrapCatalog.next_unlock(5).is_empty())

    var frost := TrapCatalog.definition(&"frost_sigil")
    assert(StringName(frost.effect) == &"frost_slow")
    assert(float(frost.strength) < 0.5)

    var trap := SpikeTrap.new()
    trap.setup(Vector2i.ZERO)
    trap.configure(frost)
    var health := HealthComponent.new()
    health.max_health = 100
    root.add_child(health)
    health.reset()
    var applied := {"effect": &""}
    trap.status_applied.connect(func(effect_id: StringName, _duration: float, _strength: float): applied.effect = effect_id)
    assert(trap.try_trigger(health))
    assert(health.current_health == 85)
    assert(applied.effect == &"frost_slow")
    print("Trap unlock catalog test passed")
    quit(0)
