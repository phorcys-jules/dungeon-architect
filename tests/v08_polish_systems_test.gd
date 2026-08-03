extends SceneTree

func _init() -> void:
    _test_intents()
    _test_guided_campaign()
    _test_formations()
    _test_rescue()
    _test_debrief()
    _test_localization()
    _test_difficulty()
    _test_campaign_persistence()
    print("v0.8 polish systems test passed")
    quit()

func _test_intents() -> void:
    var runtime := TacticalIntentRuntime.new()
    var result := runtime.announce("scout", &"sabotage", Vector2i(1, 1), Vector2i(4, 3), 2.0)
    assert(bool(result.ok))
    assert(String(result.intent.shape) == "diamond")
    assert(float(runtime.threat_cells()[Vector2i(4, 3)]) == 0.9)
    assert(runtime.update(1.0).is_empty())
    assert(runtime.update(1.0) == ["scout"])

func _test_guided_campaign() -> void:
    var guide := GuidedCampaignRuntime.new()
    assert(int(guide.current().seed) == GuidedCampaignRuntime.SEED)
    for step in GuidedCampaignRuntime.STEPS:
        assert(StringName(guide.current().id) == step)
        assert(guide.observe(step))
    assert(guide.is_complete() and guide.current().is_empty())
    guide.restart()
    guide.skip()
    assert(guide.current().is_empty())

func _test_formations() -> void:
    var runtime := SquadFormationRuntime.new()
    var members: Array[String] = ["ghost", "slime", "spider"]
    assert(bool(runtime.configure("alpha", &"pack", "ghost", members).ok))
    assert(String(runtime.target_for("slime", Vector2i(3, 3), Vector2i(8, 5)).source) == "pack")
    assert(runtime.issue_order("alpha", &"converge", Vector2i(6, 4), 1.0))
    assert(Vector2i(runtime.target_for("slime", Vector2i.ZERO, Vector2i.ZERO).target) == Vector2i(6, 4))
    assert(String(runtime.target_for("slime", Vector2i.ZERO, Vector2i.ZERO, Vector2i(1, 8)).source) == "panic")
    runtime.tick(1.1)
    assert(runtime.temporary_orders.is_empty())

func _test_rescue() -> void:
    var rescue := PrisonerRescueRuntime.new()
    var cells: Array[Vector2i] = [Vector2i(2, 2), Vector2i(3, 2)]
    var scheduled := rescue.schedule(7, {"id": "captive", "rank": 2}, &"sun_order", cells)
    assert(bool(scheduled.ok) and bool(scheduled.event.announced))
    assert(Array(scheduled.event.responses).size() == 3)
    var resolved := rescue.resolve(&"defended")
    assert(bool(resolved.ok) and int(resolved.result.reward) == 25)
    assert(rescue.active.is_empty() and rescue.history.size() == 1)

func _test_debrief() -> void:
    var replay := ReplayTimeline.new()
    replay.begin(42, GameVersion.VALUE)
    replay.record(0.0, &"run_start", "campaign", Vector2i.ZERO)
    replay.record(5.0, &"attack", "scout", Vector2i(5, 4))
    replay.record(12.0, &"run_end", "campaign", Vector2i(8, 5))
    var debrief := TacticalDebriefRuntime.new()
    var report := debrief.analyze({"victory": false, "stole_treasure": true, "damage_taken": 90, "captures": 0}, replay)
    assert(Array(report.findings).size() == 3)
    assert(String(report.findings[0].id) == "treasure_exposed")
    assert(not Dictionary(report.findings[0].evidence).is_empty())

func _test_localization() -> void:
    var localization := LocalizationRuntime.new()
    assert(localization.text("tutorial.choose_route").begins_with("Choisissez"))
    assert(localization.set_locale(&"en"))
    assert(localization.text("tutorial.choose_route").begins_with("Choose"))
    assert(localization.text("missing.key") == "[missing.key]")
    for missing in localization.coverage().values():
        assert(Array(missing).is_empty())

func _test_difficulty() -> void:
    var director := DifficultyDirector.new()
    assert(director.select_profile(&"discovery"))
    assert(int(director.selected_rules().mistake_tolerance) == 2)
    var samples: Array[Dictionary] = []
    for index in 100:
        samples.append({"victory": index % 2 == 0, "solvable": true, "trap_ids": ["spikes", "frost"], "monster_ids": ["ghost", "slime"]})
    var report := director.balance_report(samples)
    assert(bool(report.ok) and is_equal_approx(float(report.win_rate), 0.5))
    var bad_report := director.balance_report([{"victory": false, "solvable": false, "trap_ids": [], "monster_ids": []}])
    assert(not bool(bad_report.ok) and Array(bad_report.alerts).has("insoluble_seeds"))

func _test_campaign_persistence() -> void:
    var campaign := V08CampaignRuntime.new()
    campaign.start(808)
    campaign.localization.set_locale(&"en")
    campaign.difficulty.select_profile(&"ruthless")
    assert(campaign.effective_difficulty_profile() == &"ruthless")
    campaign.daily_active = true
    assert(campaign.effective_difficulty_profile() == &"architect")
    campaign.daily_active = false
    campaign.guided_campaign.observe(&"choose_route")
    var saved := campaign.to_dict()
    var restored := V08CampaignRuntime.new()
    restored.from_dict(saved)
    assert(restored.localization.locale == &"en")
    assert(restored.difficulty.selected_profile == &"ruthless")
    assert(restored.guided_campaign.completed == [&"choose_route"])
