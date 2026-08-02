extends SceneTree

func _init() -> void:
    var wallet := VillageCurrency.new()
    assert(wallet.balance == 0)
    assert(wallet.deposit(100) == 100)
    assert(wallet.formatted() == "◆ 100")
    assert(wallet.can_afford(60))
    assert(wallet.spend(60))
    assert(wallet.balance == 40)
    assert(not wallet.spend(41))
    assert(wallet.balance == 40)

    var restored := VillageCurrency.new()
    restored.restore(wallet.serialize())
    assert(restored.balance == 40)

    var legacy_den := DenProgression.new()
    legacy_den.restore({"level": 2, "stored_resources": 75})
    assert(legacy_den.level == 2)
    assert(legacy_den.soul_shards == 75)
    assert(legacy_den.serialize().currency.soul_shards == 75)
    print("Village currency test passed")
    quit(0)
