extends SceneTree

const Nemesis := preload("res://scripts/meta/nemesis_runtime.gd")
const FlowRuntime := preload("res://scripts/run/environment_flow_runtime.gd")
const Blueprints := preload("res://scripts/build/blueprint_runtime.gd")
const Quests := preload("res://scripts/village/village_quest_runtime.gd")
const Accessibility := preload("res://scripts/presentation/accessibility_profile.gd")
const Daily := preload("res://scripts/run/daily_challenge_runtime.gd")
const Campaign := preload("res://scripts/run/v08_campaign_runtime.gd")

func _init() -> void:
    var campaign := Campaign.new()
    campaign.start(8080)
    assert(campaign.world_map.columns.size() == 9)
    assert(campaign.available_routes().size() == 3)
    var first_route := campaign.available_routes()[0]
    assert(bool(campaign.choose_route(String(first_route.id)).ok))
    assert(campaign.run_tags().size() == 3)
    var restored_campaign := Campaign.new()
    restored_campaign.from_dict(campaign.to_dict())
    assert(restored_campaign.world_map.current_node_id == campaign.world_map.current_node_id)

    var boss := BossEncounter.new()
    var boss_definition := BossCatalog.new().get_boss("paladin_captain")
    assert(boss.start("paladin_captain", boss_definition))
    assert(not boss.consume_phase_intent().is_empty())
    boss.take_damage(300.0)
    assert(boss.current_phase > 0)
    assert(bool(boss.resolve_architecture_action([Vector2i(2, 2)], [Vector2i.ZERO]).ok))

    var progression := MonsterProgression.new()
    progression.ensure_monster("ghost", "spectral")
    progression.monsters.ghost.level = 7
    assert(progression.choose_evolution("ghost", "wraith"))
    assert(progression.choose_mutation("ghost", "volatile"))
    assert(String(progression.gameplay_profile("ghost").ability) == "death_burst")
    assert(float(progression.stat_multipliers("ghost").damage) > 1.0)
    assert(bool(progression.reset_evolution("ghost", 30).ok))

    var nemesis := Nemesis.new()
    nemesis.promote("thief", "Iria", {"stole_treasure": true, "trap_ids": ["spikes"], "monster_ids": ["ghost"]})
    nemesis.record_encounter("thief", {"trap_ids": ["spikes"], "monster_ids": ["ghost"]})
    assert(nemesis.report("thief", 3).adaptations.size() == 2)
    assert(bool(nemesis.defeat("thief").ok))

    var environment := FlowRuntime.new()
    environment.seed(Vector2i(1, 1), &"fire", 3)
    environment.seed(Vector2i(2, 1), &"water", 2)
    var flow := environment.step(Vector2i(5, 5), [])
    assert(flow.interactions.any(func(entry): return String(entry.name) == "steam"))
    assert(environment.movement_cost(Vector2i(2, 1), []) > 0.0)

    var blueprints := Blueprints.new()
    assert(blueprints.capture("gate", [{"cell": Vector2i(2, 2), "kind": "wall", "content_id": "wall", "cost": 12}], Vector2i(2, 2)))
    var preview := blueprints.preview("gate", Vector2i(5, 5))
    assert(bool(preview.ok) and int(preview.cost) == 12)
    assert(bool(blueprints.validate_purchase(preview, 12, true, ["wall"]).ok))
    var challenge_code := blueprints.export_challenge(8080, campaign.to_dict())
    assert(int(blueprints.import_challenge(challenge_code).seed) == 8080)

    var quests := Quests.new()
    assert(quests.record("combos", 6).size() == 1)
    assert(String(quests.current_quest(&"blacksmith").id) == "tested_edges")

    var accessibility := Accessibility.new()
    assert(accessibility.rebind(&"start_wave", KEY_ENTER))
    assert(accessibility.set_palette(&"deuteranopia"))
    assert(accessibility.color(0) != accessibility.color(1))

    var daily := Daily.new()
    var challenge := daily.definition("2026-08-03", "v0.8.0-alpha")
    assert(challenge.seed == daily.seed_for("2026-08-03", "v0.8.0-alpha"))
    assert(daily.is_compatible(challenge, "v0.8.0-alpha"))

    print("v0.8 campaign systems test passed")
    quit()
