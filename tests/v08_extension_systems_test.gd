extends SceneTree

const Prisoners := preload("res://scripts/meta/prisoner_runtime.gd")
const Sabotage := preload("res://scripts/run/sabotage_runtime.gd")
const Patrols := preload("res://scripts/ai/patrol_zone_runtime.gd")
const Replay := preload("res://scripts/run/replay_timeline.gd")
const AudioDirector := preload("res://scripts/presentation/reactive_audio_director.gd")
const Challenges := preload("res://scripts/run/custom_challenge_runtime.gd")

func _init() -> void:
    _test_prisoners()
    _test_sabotage()
    _test_patrols()
    _test_replay()
    _test_audio()
    _test_challenges()
    _test_campaign_persistence()
    print("v0.8 extension systems test passed")
    quit()

func _test_prisoners() -> void:
    var runtime := Prisoners.new()
    runtime.set_capacity(2)
    assert(bool(runtime.capture("scout", "Iria", &"free_blades", 2, 42).ok))
    assert(not bool(runtime.capture("scout", "Iria", &"free_blades", 2, 42).ok))
    assert(runtime.rescue_targets(&"free_blades") == ["scout"])
    var intel := runtime.decide("scout", &"interrogate", 2)
    assert(bool(intel.ok) and intel.intel.facts.size() == 3)
    var restored := Prisoners.new()
    restored.from_dict(runtime.to_dict())
    assert(restored.prisoners.has("scout"))

func _test_sabotage() -> void:
    var runtime := Sabotage.new()
    var target := {"id": "trap:1", "kind": "trap", "cell": Vector2i(1, 1), "valid": true}
    var scheduled := runtime.schedule(8, &"sun_order", [target], 3)
    assert(bool(scheduled.ok) and String(scheduled.preview.counter) != "unknown")
    var counter := StringName(scheduled.preview.counter)
    assert(bool(runtime.resolve([counter], true).blocked))
    runtime.schedule(8, &"sun_order", [target], 3)
    assert(not bool(runtime.resolve([], true).blocked))

func _test_patrols() -> void:
    var runtime := Patrols.new()
    var reachable: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
    assert(bool(runtime.define("guard", &"guard", reachable, reachable).ok))
    assert(runtime.assign("ghost", "guard"))
    assert(String(runtime.target_for("ghost", Vector2i(1, 1)).source) == "guard")
    var emergency := runtime.target_for("ghost", Vector2i(1, 1), Vector2i(9, 9))
    assert(String(emergency.source) == "emergency" and String(emergency.return_zone) == "guard")
    runtime.order(["ghost"], Vector2i(5, 5))
    assert(String(runtime.target_for("ghost", Vector2i.ZERO).source) == "temporary_order")
    runtime.clear_orders()

func _test_replay() -> void:
    var runtime := Replay.new()
    runtime.begin(88, GameVersion.VALUE)
    runtime.record(0.0, &"run_start", "master", Vector2i.ZERO)
    runtime.record(1.25, &"trap", "spikes", Vector2i(2, 2), {"damage": 35})
    assert(String(runtime.next("", &"trap").actor) == "spikes")
    var code := runtime.export_code()
    var restored := Replay.new()
    assert(bool(restored.import_code(code, GameVersion.VALUE).ok))
    assert(restored.events.size() == 2 and restored.estimated_bytes() < 2048)
    assert(not bool(Replay.new().import_code(code, "v9").ok))

func _test_audio() -> void:
    var runtime := AudioDirector.new()
    runtime.configure(&"mine", &"arcane_circle", {"music": 0.8, "reduced_sensory": true})
    var snapshot := runtime.update(1.0, 0.25)
    assert(float(snapshot.weights.tension) <= 0.8)
    assert(bool(runtime.stinger(&"rival").play))
    assert(not runtime.should_load_audio(true))

func _test_challenges() -> void:
    var runtime := Challenges.new()
    var configured := runtime.configure(77, &"crypt", &"free_blades", "royal_huntress", [&"scarce_currency", &"fast_adventurers"], {"required": ["fog_chamber"]})
    assert(bool(configured.ok) and runtime.score_multiplier() > 1.0)
    assert(not bool(runtime.validate_unlocks([]).ok))
    assert(bool(runtime.validate_unlocks(["fog_chamber"]).ok))
    var code := runtime.export_code()
    var restored := Challenges.new()
    assert(bool(restored.import_code(code).ok))
    assert(int(restored.configuration.seed) == 77 and not bool(restored.configuration.persistent_rewards))
    assert(not bool(Challenges.new().configure(1, &"crypt", &"sun_order", "", [&"scarce_currency", &"abundant_currency"]).ok))

func _test_campaign_persistence() -> void:
    var campaign := V08CampaignRuntime.new()
    campaign.start(200)
    var route := campaign.available_routes()[0]
    campaign.choose_route(String(route.id))
    campaign.prisoners.capture("mage", "Lux", &"arcane_circle", 3, 10)
    campaign.patrols.define("home", &"guard", [Vector2i.ONE], [Vector2i.ONE])
    campaign.replay.begin(200, GameVersion.VALUE)
    campaign.replay.record(0.0, &"run_start", "master", Vector2i.ZERO)
    var restored := V08CampaignRuntime.new()
    restored.from_dict(campaign.to_dict())
    assert(restored.prisoners.prisoners.has("mage"))
    assert(restored.patrols.zones.has("home"))
    assert(restored.replay.events.size() == 1)
