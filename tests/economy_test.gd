extends SceneTree

const EconomyScript := preload("res://scripts/core/economy.gd")

func _init() -> void:
    var economy: Economy = EconomyScript.new()
    economy.starting_gold = 100
    economy.reset()

    assert(economy.current_gold == 100)
    assert(economy.can_afford(25))
    assert(economy.spend(25))
    assert(economy.current_gold == 75)
    assert(not economy.spend(80))
    assert(economy.current_gold == 75)

    economy.add_gold(30)
    assert(economy.current_gold == 105)
    economy.add_gold(-10)
    assert(economy.current_gold == 105)

    print("Economy test passed")
    quit(0)
