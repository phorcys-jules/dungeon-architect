extends SceneTree

func _init() -> void:
    var started := Time.get_ticks_msec()
    for seed_value in 100:
        var campaign := V08CampaignRuntime.new()
        campaign.start(seed_value)
        var safety := 0
        while not campaign.world_map.is_complete() and safety < 12:
            var routes := campaign.available_routes()
            assert(not routes.is_empty())
            assert(bool(campaign.choose_route(String(routes[seed_value % routes.size()].id)).ok))
            safety += 1
        assert(campaign.world_map.is_complete())
        assert(safety <= 9)
        var final_node := campaign.world_map.find_node(campaign.world_map.current_node_id)
        assert(int(final_node.type) == RogueliteWorldMap.NodeType.BOSS)
    var duration := Time.get_ticks_msec() - started
    assert(duration < 5000)
    print("v0.8 seed stability test passed: 100 campaigns in %d ms" % duration)
    quit()
