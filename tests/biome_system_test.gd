extends SceneTree

func _init() -> void:
    var catalog := BiomeCatalog.new()
    assert(catalog.all_ids().size() == 4)
    assert(not catalog.get_biome(BiomeCatalog.CRYPT).is_empty())
    assert(catalog.validate_room_tags(BiomeCatalog.SEWERS, ["slime"]).ok)
    assert(not catalog.validate_room_tags(BiomeCatalog.SEWERS, ["fire"]).ok)
    assert(catalog.has_required_room(BiomeCatalog.MINE, ["corridor"]))
    assert(not catalog.has_required_room(BiomeCatalog.MINE, ["curse"]))

    var runtime := BiomeRuntime.new()
    assert(runtime.set_active(BiomeCatalog.CASTLE))
    assert(runtime.wall_cost(10) == 12)
    assert(is_equal_approx(runtime.rule_value("door_health_multiplier"), 1.4))
    assert(runtime.can_start_run(["control"]))

    var selected_a := runtime.select_for_zone(1234, 2)
    var runtime_b := BiomeRuntime.new()
    var selected_b := runtime_b.select_for_zone(1234, 2)
    assert(selected_a == selected_b)

    var restored := BiomeRuntime.new()
    restored.from_dict(runtime.to_dict())
    assert(restored.active_biome_id == runtime.active_biome_id)

    print("biome system test passed")
    quit()
