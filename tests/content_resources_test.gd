extends SceneTree

func _init() -> void:
    var scout := load("res://resources/adventurers/scout.tres") as AdventurerData
    var warrior := load("res://resources/adventurers/warrior.tres") as AdventurerData
    var champion := load("res://resources/adventurers/champion.tres") as AdventurerData
    var wave_one := load("res://resources/waves/wave_01.tres") as WaveData
    var wave_two := load("res://resources/waves/wave_02.tres") as WaveData
    var wave_three := load("res://resources/waves/wave_03.tres") as WaveData

    assert(scout != null and scout.is_valid())
    assert(warrior != null and warrior.is_valid())
    assert(champion != null and champion.is_valid())
    assert(scout.speed_multiplier > warrior.speed_multiplier)
    assert(champion.max_health > warrior.max_health)

    assert(wave_one != null and wave_one.is_valid())
    assert(wave_two != null and wave_two.is_valid())
    assert(wave_three != null and wave_three.is_valid())
    assert(wave_one.wave_number == 1)
    assert(wave_two.adventurer.id == "warrior")
    assert(wave_three.get_total_reward() == 85)

    print("Content resources test passed")
    quit(0)
