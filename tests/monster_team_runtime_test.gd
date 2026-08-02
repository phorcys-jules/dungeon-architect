extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

func _init() -> void:
    var game := MainScene.instantiate()
    root.add_child(game)
    await process_frame

    var selected_team: Array[String] = ["ghost", "mimic"]
    game.set_monster_team(selected_team)
    game._spawn_mobile_monsters()
    assert(game.active_monster_archetypes.size() == 2)
    assert(game.mobile_monsters.size() == 2)
    assert(game.get_monster_ids() == ["ghost", "mimic"])
    assert(game.mobile_monsters[0].home_cell == game.MONSTER_HOME_CELLS[0])
    assert(game.mobile_monsters[1].home_cell == game.MONSTER_HOME_CELLS[1])

    game.monster_progression.ensure_monster("ghost", "spectral")
    var base_progression: Dictionary = game._monster_progression_multipliers("ghost")
    game.monster_progression.grant_experience("ghost", 200)
    var progression: Dictionary = game._monster_progression_multipliers("ghost")
    assert(float(progression.health) > float(base_progression.health))
    assert(float(progression.damage) > float(base_progression.damage))

    print("Monster team runtime test passed")
    quit(0)
