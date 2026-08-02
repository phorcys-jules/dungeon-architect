extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

func _init() -> void:
    var game := MainScene.instantiate()
    root.add_child(game)
    await process_frame
    assert(game.MONSTER_ARCHETYPES.size() == 4)
    assert(game.mobile_monsters.size() == 4)
    assert(game.placed_rooms.size() == 5)
    assert(game.get_monster_ids() == ["ghost", "slime", "mimic", "spider"])
    var tags: Array[String] = game.get_run_tags()
    for required_tag in ["monster:ghost", "monster:slime", "monster:mimic", "monster:spider"]:
        assert(tags.has(required_tag))
    assert(tags.any(func(tag: String) -> bool: return tag.begins_with("biome:")))
    for texture in game.MONSTER_TEXTURES.values():
        assert(texture != null)
    for texture in game.ADVENTURER_TEXTURES.values():
        assert(texture != null)
    print("V0.6 content wiring test passed")
    quit(0)
