extends SceneTree

func _init() -> void:
    var catalog := BiomeCatalog.new()
    assert(catalog.all_ids().size() == 4)
    for biome_id in catalog.all_ids():
        var definition := catalog.get_biome(biome_id)
        assert(not definition.is_empty())
        assert(Dictionary(definition.palette).size() == 5)
        assert(not Dictionary(definition.rules).is_empty())
    assert(catalog.validate_room_tags(BiomeCatalog.SEWERS, ["slime"]).ok)
    assert(not catalog.validate_room_tags(BiomeCatalog.SEWERS, ["fire"]).ok)
    assert(catalog.has_required_room(BiomeCatalog.MINE, ["corridor"]))
    assert(not catalog.has_required_room(BiomeCatalog.MINE, ["curse"]))

    var runtime := BiomeRuntime.new()
    assert(runtime.set_active(BiomeCatalog.CASTLE))
    assert(runtime.wall_cost(10) == 12)
    assert(runtime.can_start_run(["control"]))
    assert(runtime.rule_value("starting_gold_adjustment", 0.0) == 15.0)

    var selected_a := runtime.select_for_zone(1234, 2)
    var runtime_b := BiomeRuntime.new()
    var selected_b := runtime_b.select_for_zone(1234, 2)
    assert(selected_a == selected_b)

    var restored := BiomeRuntime.new()
    restored.from_dict(runtime.to_dict())
    assert(restored.active_biome_id == runtime.active_biome_id)

    print("biome system test passed")
    quit()
