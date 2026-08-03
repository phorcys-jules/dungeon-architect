extends SceneTree

func _init() -> void:
    var record := RunResultRecord.new()
    record.run_id = "test-run"
    record.waves_completed = 4
    record.damage_dealt = 1200
    record.traps_triggered = 8
    record.monsters_lost = 1
    record.treasure_protected = true
    record.victory = true
    record.difficulty_id = "hard"

    var reward := RunPerformanceCalculator.new().calculate(record)
    if int(reward.get("score", 0)) <= 0 or int(reward.get("gold", 0)) <= 0:
        quit(1)
        return
    record.score = int(reward.score)
    record.gold_reward = int(reward.gold)
    record.essence_reward = int(reward.essence)
    var serialized := RunResultRecord.from_dict(record.to_dict())
    if serialized.score != record.score or serialized.gold_reward != record.gold_reward or serialized.essence_reward != record.essence_reward:
        quit(1)
        return

    var history := RunHistory.new()
    for index in range(25):
        var item := RunResultRecord.from_dict(record.to_dict())
        item.run_id = "run-%d" % index
        history.add(item)
    if history.entries.size() != RunHistory.MAX_ENTRIES:
        quit(1)
        return
    var restored := RunHistory.new()
    restored.load_array(history.to_array())
    if restored.entries.size() != RunHistory.MAX_ENTRIES or restored.entries[0].run_id != "run-24":
        quit(1)
        return

    print("Run results test passed")
    quit(0)
