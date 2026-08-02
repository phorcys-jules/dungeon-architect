extends SceneTree

func _init() -> void:
    var ledger := RunLootLedger.new()
    ledger.collect_relic(3)
    ledger.collect_relic(2)
    ledger.record_monster_neutralized(Vector2i(4, 4), 1, 2)
    assert(ledger.carried_loot == 5)
    assert(ledger.ectoplasm_net() == -1)
    assert(ledger.capture_adventurer(Vector2i(5, 4)) == 5)
    assert(ledger.carried_loot == 0 and ledger.captured_loot == 5)
    assert(ledger.world_drops.size() == 2)
    var restored := ledger.snapshot()
    assert(int(restored.ectoplasm) == 1)
    assert(int(restored.monster_recovery_cost) == 2)
    print("Run loot ledger test passed")
    quit(0)
