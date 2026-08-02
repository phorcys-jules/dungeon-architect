extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

func _init() -> void:
    var game := MainScene.instantiate()
    root.add_child(game)
    await process_frame
    assert(game.MONSTER_ARCHETYPES.size() == 4)
    assert(game.mobile_monsters.size() == 4)
    assert(game.monster_ability_cooldowns.size() == 4)
    assert(game.monster_burst_available == [true, true, true, true])
    var combat_target: MobileMonster = game.mobile_monsters[0]
    combat_target.world_position = Vector2(game.ENTRANCE) * game.CELL_SIZE
    var previous_monster_health := combat_target.current_health
    assert(game._try_adventurer_attack())
    assert(combat_target.current_health < previous_monster_health)
    combat_target.reset_to_home(game.CELL_SIZE)
    for index in game.mobile_monsters.size():
        var expected_position: Vector2 = Vector2(game.MONSTER_HOME_CELLS[index]) * game.CELL_SIZE
        assert(game.mobile_monsters[index].world_position == expected_position)
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
    for texture in [game.RELIC_TEXTURE, game.BLESSING_TEXTURE, game.TREASURE_TEXTURE]:
        assert(texture != null)
        assert(texture.get_width() == 128)
        assert(texture.get_height() == 128)
    game.combat_effects.clear()
    game._spawn_combat_effect(&"projectile", Vector2.ZERO, Vector2.RIGHT * 48.0, Color.WHITE, 0.3)
    assert(game.combat_effects.size() == 1)
    game._tick_combat_presentation(0.1)
    assert(float(game.combat_effects[0].remaining) < 0.3)
    game.combat_effects.clear()
    combat_target.revive_at_home(game.CELL_SIZE)
    combat_target.world_position = Vector2(game.ENTRANCE) * game.CELL_SIZE
    combat_target.set_path([Vector2i(1, 5)])
    game._activate_power_pellet()
    assert(game.loop_rules.is_panicking())
    assert(not game.blessing_available)
    assert(not combat_target.has_path())
    game.adventurer_attack_cooldown = 0.0
    var powered_health := combat_target.current_health
    assert(game._try_adventurer_attack())
    assert(powered_health - combat_target.current_health > int(game.AdventurerCombatAiScript.profile("scout").damage))
    game.loop_rules.tick(game.loop_rules.panic_duration)
    game._on_power_pellet_expired()
    assert(not game.loop_rules.is_panicking())
    combat_target.revive_at_home(game.CELL_SIZE)
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
    game._apply_monster_zone_ability(1, game.MONSTER_ARCHETYPES[1], Vector2i(1, 1), Vector2i(2, 1))
    assert(game.slime_trails.has(Vector2i(1, 1)))
    var crossroads_cell := Vector2i(-1, -1)
    for room_cell: Vector2i in game.placed_rooms:
        if (game.placed_rooms[room_cell] as RoomData).room_id == "crossroads":
            crossroads_cell = room_cell
    assert(crossroads_cell != Vector2i(-1, -1))
    game._apply_monster_zone_ability(3, game.MONSTER_ARCHETYPES[3], crossroads_cell, crossroads_cell)
    assert(game.spider_webs.has(crossroads_cell))
    print("V0.6 content wiring test passed")
    quit(0)
