extends SceneTree

func _init() -> void:
    var path := "user://v06_full_run_integration_test.json"
    var store := V06ProgressionStore.new(path)
    store.delete_save()
    var integration := V06RunIntegration.new(store)
    integration.begin_run(42, ["monster:ghost", "monster:slime", "monster:mimic", "monster:spider", "room:fog", "biome:crypt"])
    assert(integration.challenges.active.size() == 3)
    assert(integration.synergies.discovered.has("ghost_fog"))
    assert(not integration.start_wave(1, "crypt").is_empty())
    integration.events.active_events = [{
        "id": "effects_test",
        "name": "Effets test",
        "description": "Description test",
        "remaining": 2,
        "effects": {"monster_damage_multiplier": 1.25, "monster_speed_multiplier": 0.8, "trap_cooldown_multiplier": 0.65},
    }]
    assert(is_equal_approx(integration.event_multiplier("monster_damage_multiplier"), 1.25))
    assert(is_equal_approx(integration.event_multiplier("monster_speed_multiplier"), 0.8))
    assert(is_equal_approx(integration.event_multiplier("trap_cooldown_multiplier"), 0.65))
    var snapshot := integration.hud_snapshot()
    assert(String(snapshot.challenges[0]).contains("/"))
    assert(String(snapshot.challenges[0]).contains("+"))
    assert(snapshot.event_history.size() == 1)
    assert(not String(integration.hud_snapshot().effect_entries[0].description).is_empty())
    integration.synergies.active = [integration.synergies.catalog.get_entry("ghost_fog"), integration.synergies.catalog.get_entry("mimic_treasure")]
    assert(is_equal_approx(integration.synergy_bonus("evasion"), 0.20))
    assert(is_equal_approx(integration.synergy_bonus("ambush_damage"), 0.35))
    integration.record_capture()
    var summary := integration.finish_run({"victory": true, "wave": 5, "score": 500, "captures": 1, "resources": {"gold": 20}, "monster_ids": ["ghost"]})
    assert(int(summary.result.resources.gold) >= 20)
    assert(integration.global_stats.total_runs == 1)
    assert(integration.encyclopedia.state_of("monster_ghost") == EncyclopediaCatalog.DiscoveryState.DISCOVERED)
    assert(integration.encyclopedia.state_of("monster_mimic") == EncyclopediaCatalog.DiscoveryState.DISCOVERED)

    var restored := V06RunIntegration.new(store)
    restored.begin_run(43, ["monster:ghost", "room:fog", "biome:crypt"])
    assert(restored.global_stats.total_runs == 1)
    assert(restored.synergies.discovered.has("ghost_fog"))

    var legacy := SaveMigrator.new().migrate({"version": 3, "resources": {"gold": 12}, "run_history": [{"victory": false}]})
    assert(int(legacy.version) == 4)
    assert(int(legacy.resources.gold) == 12)
    assert(legacy.run_history.size() == 1)
    restored.record_capture()
    restored.finish_run({"victory": false, "wave": 2, "score": 120, "captures": 1, "resources": {"gold": 3}, "monster_ids": ["ghost"]})
    var reloaded := V06RunIntegration.new(store)
    reloaded.begin_run(44, ["monster:ghost", "room:fog", "biome:crypt"])
    assert(reloaded.global_stats.total_runs == 2)
    store.delete_save()
    print("v0.6 full run integration test passed")
    quit()
