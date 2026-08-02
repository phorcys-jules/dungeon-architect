extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

func _init() -> void:
    var selection := RoomDeckSelection.new()
    var chosen: Array[String] = ["corridor", "crossroads", "treasure_hall"]
    assert(bool(selection.select(chosen).ok))
    assert(not bool(selection.add("treasure_hall").ok))
    assert(not bool(selection.validate_for_biome().ok))
    assert(bool(selection.set_biome(BiomeCatalog.MINE).ok))
    assert(bool(selection.validate_for_biome().ok))
    var restored := RoomDeckSelection.new()
    restored.from_dict(selection.to_dict())
    assert(restored.selected == chosen)
    assert(restored.biome_id == BiomeCatalog.MINE)

    var game := MainScene.instantiate()
    root.add_child(game)
    await process_frame
    assert(game.set_room_deck(chosen))
    game._build_level()
    assert(game.placed_rooms.size() == chosen.size())
    var generated_ids: Array[String] = []
    for room: RoomData in game.placed_rooms.values():
        generated_ids.append(room.room_id)
    generated_ids.sort()
    var expected_ids := chosen.duplicate()
    expected_ids.sort()
    assert(generated_ids == expected_ids)
    root.remove_child(game)
    game.free()
    print("Room deck selection integration test passed")
    quit(0)
