extends SceneTree

const MainScene := preload("res://scenes/main.tscn")


func _init() -> void:
    var game = MainScene.instantiate()
    game.status_label = Label.new()
    game._spawn_mobile_monsters()

    var mimic_index := -1
    for index in game.active_monster_archetypes.size():
        if game.active_monster_archetypes[index].archetype_id == &"mimic":
            mimic_index = index
            break
    assert(mimic_index >= 0)

    var mimic: MobileMonster = game.mobile_monsters[mimic_index]
    mimic.activation_delay_left = 0.0
    # mimic should start disguised and not revealed
    assert(not game.monster_revealed[mimic_index])
    assert(mimic.disguised)
    assert(not game._try_reveal_mimic(mimic.cell + Vector2i.RIGHT, false))
    assert(not game.monster_revealed[mimic_index])
    assert(game._try_reveal_mimic(mimic.cell, false))
    assert(game.monster_revealed[mimic_index])
    # reveal should clear disguise
    assert(not mimic.disguised)

    game._disguise_mimic(mimic_index)
    assert(not game.monster_revealed[mimic_index])

    game.status_label.free()
    game.free()
    print("mimic_ambush_behavior_test: OK")
    quit()
