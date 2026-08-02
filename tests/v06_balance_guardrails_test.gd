extends SceneTree

func _init() -> void:
    var waves := WaveManager.new()
    var previous_health := 0
    var previous_reward := 0
    var previous_preparation := 999.0
    for wave_number in range(1, WaveManager.MAX_WAVES + 1):
        waves.current_wave = wave_number
        assert(waves.get_adventurer_health() >= previous_health)
        assert(waves.get_wave_reward() >= previous_reward)
        assert(waves.get_preparation_duration() <= previous_preparation)
        previous_health = waves.get_adventurer_health()
        previous_reward = waves.get_wave_reward()
        previous_preparation = waves.get_preparation_duration()

    var challenge_catalog := RunChallengeCatalog.new()
    for challenge_id in challenge_catalog.all_ids():
        var reward: Dictionary = challenge_catalog.get_definition(challenge_id).reward
        assert(int(reward.gold) >= 35 and int(reward.gold) <= 75)
        assert(int(reward.essence) >= 5 and int(reward.essence) <= 15)

    var event_catalog := RunEventCatalog.new()
    for event_id in event_catalog.definitions:
        var effects: Dictionary = event_catalog.definitions[event_id].effects
        for key in effects:
            if String(key).ends_with("_multiplier"):
                assert(float(effects[key]) >= 0.4 and float(effects[key]) <= 1.6)

    assert(_starting_budget_can_build_a_defence())
    print("v0.6 balance guardrails test passed")
    quit()

func _starting_budget_can_build_a_defence() -> bool:
    var economy := Economy.new()
    economy.starting_gold = 100
    economy.reset()
    return economy.can_afford(40) and economy.can_afford(25)
