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
        assert(texture.get_width() == 512)
        assert(texture.get_height() == 128)
    for texture in game.ADVENTURER_TEXTURES.values():
        assert(texture != null)
        assert(texture.get_width() == 512)
        assert(texture.get_height() == 128)
    assert(game.MonsterSprite.get_width() == 512)
    assert(game.MonsterSprite.get_height() == 128)
    assert(game.ROOM_TEXTURES.size() == 5)
    for room_id in ["slime_pool", "crossroads", "false_treasure", "monster_portal", "fog_chamber"]:
        var room_texture: Texture2D = game.ROOM_TEXTURES.get(room_id)
        assert(room_texture != null)
        assert(room_texture.get_width() == 128)
        assert(room_texture.get_height() == 128)
    var first_room_cell: Vector2i = game.placed_rooms.keys()[0]
    assert(not game._is_valid_build_cell(first_room_cell))
    var click := InputEventMouseButton.new()
    click.button_index = MOUSE_BUTTON_LEFT
    click.pressed = true
    click.position = game._world_from_cell(first_room_cell)
    game._unhandled_input(click)
    assert(not game.status_label.text.is_empty())
    print("V0.6 content wiring test passed")
    quit(0)
