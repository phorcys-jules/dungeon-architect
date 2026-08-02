extends SceneTree

func _init() -> void:
    var world_map := RogueliteWorldMap.new()
    world_map.generate(42)

    var service := BossMapService.new()
    var intro: Dictionary = service.prepare_for_map(world_map)
    assert(not intro.is_empty())
    assert(int(intro.phase_count) == 3)

    var first_ability := service.encounter.current_ability()
    service.encounter.take_damage(float(service.encounter.definition.max_health) * 0.5)
    assert(service.encounter.current_phase >= 1)
    assert(service.encounter.current_ability() != first_ability)

    service.encounter.take_damage(10000.0)
    assert(service.encounter.finished)
    var result: Dictionary = service.resolve_victory()
    assert(result.ok)
    assert(int(result.reward.gold) > 0)
    assert(int(result.reward.essence) > 0)

    var ids := service.catalog.ids()
    assert(ids.size() >= 3)
    for boss_id in ids:
        var definition := service.catalog.get_boss(boss_id)
        assert(Array(definition.phases).size() == 3)
        assert(not String(definition.intro).is_empty())

    print("boss encounters test passed")
    quit()
