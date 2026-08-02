extends SceneTree

func _init() -> void:
    var candidates: Array[Dictionary] = [
        {"index": 0, "active": true, "distance": 1.0, "health_ratio": 1.0, "threat": 8.0},
        {"index": 1, "active": true, "distance": 1.5, "health_ratio": 0.2, "threat": 24.0},
    ]
    assert(AdventurerCombatAi.choose_target(candidates, &"nearest") == 0)
    assert(AdventurerCombatAi.choose_target(candidates, &"wounded") == 1)
    assert(AdventurerCombatAi.choose_target(candidates, &"dangerous") == 1)
    assert(bool(AdventurerCombatAi.profile("scout").ranged))
    assert(int(AdventurerCombatAi.profile("champion").damage) > int(AdventurerCombatAi.profile("scout").damage))

    var monster := MobileMonster.new()
    monster.setup(Vector2i(2, 2), 100.0, 20)
    assert(monster.take_damage(8) == 8)
    assert(monster.is_active())
    assert(monster.take_damage(20, 0.1) == 12)
    assert(not monster.is_active())
    assert(monster.tick_respawn(0.1, 48.0))
    assert(monster.current_health == monster.max_health)
    print("Adventurer combat AI test passed")
    quit(0)
