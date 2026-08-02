extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

func _init() -> void:
    var game := MainScene.instantiate()
    root.add_child(game)
    await process_frame
    var full_team: Array[String] = ["ghost", "slime", "mimic", "spider"]
    game.set_monster_team(full_team)
    game._spawn_mobile_monsters()
    assert(game.MONSTER_ARCHETYPES.size() == 4)
    assert(game.mobile_monsters.size() == 4)
    assert(game.monster_ability_cooldowns.size() == 4)
    assert(game.monster_burst_available == [true, true, true, true])
    assert(game.shortcut_buttons.size() == 9)
    var all_traps: Array[StringName] = []
    all_traps.assign(TrapCatalog.ORDER)
    game.set_unlocked_traps(all_traps)
    game._activate_build_shortcut(4)
    assert(game.selected_trap_id == &"frost_sigil")
    assert(game._active_build_shortcut() == 4)
    game._activate_build_shortcut(7)
    assert(game.build_mode == game.BuildMode.DEFENDER)
    game._activate_build_shortcut(8)
    assert(game.construction_mode == game.ConstructionMode.PLACE_WALL)
    game._activate_build_shortcut(9)
    assert(game.construction_mode == game.ConstructionMode.REMOVE_WALL)
    game._activate_build_shortcut(7)
    var trap_key := InputEventKey.new()
    trap_key.keycode = KEY_3
    trap_key.pressed = true
    game._unhandled_input(trap_key)
    assert(game.selected_trap_id == &"fire_rune")
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
    game.village_den.level = 2
    assert(game._max_defenders() == 6)
    var previous_synergies: Array[Dictionary] = game.v06_integration.synergies.active.duplicate(true)
    var runtime_events: Array[Dictionary] = [{
        "id": "runtime_test",
        "name": "Modificateurs actifs",
        "description": "Vérifie le branchement au gameplay.",
        "remaining": 2,
        "effects": {"monster_damage_multiplier": 1.25, "monster_speed_multiplier": 0.8, "trap_cooldown_multiplier": 0.65},
    }]
    game.v06_integration.events.active_events = runtime_events
    var runtime_synergies: Array[Dictionary] = [
        game.v06_integration.synergies.catalog.get_entry("ghost_fog"),
        game.v06_integration.synergies.catalog.get_entry("slime_ice"),
        game.v06_integration.synergies.catalog.get_entry("mimic_treasure"),
    ]
    game.v06_integration.synergies.active = runtime_synergies
    assert(is_equal_approx(game._monster_speed_multiplier(), 0.8))
    assert(is_equal_approx(game._monster_evasion(&"ghost"), 0.2))
    assert(is_equal_approx(game._monster_ambush_multiplier(&"mimic", true), 1.35))
    assert(is_equal_approx(game._slime_slow_multiplier(0.72), 0.54))
    var accelerated_trap := SpikeTrap.new()
    accelerated_trap.configure(TrapCatalog.definition(&"spikes"))
    game._configure_trap(accelerated_trap)
    assert(is_equal_approx(accelerated_trap.cooldown_duration, 1.5 * 0.65))
    game._refresh_v06_hud()
    assert(game.effect_rows.any(func(row: Button): return row.text == "Modificateurs actifs" and not row.tooltip_text.is_empty()))
    game.v06_integration.events.active_events.clear()
    game.v06_integration.synergies.active = previous_synergies
    var previous_modifiers: Dictionary = game.village_modifiers.duplicate(true)
    game.village_modifiers = {
        "trap_damage_multiplier": 0.2,
        "effect_duration_multiplier": 0.4,
        "monster_respawn_speed_multiplier": 0.5,
        "monster_damage_multiplier": 0.25,
        "monster_health_multiplier": 0.2,
    }
    var linked_trap := SpikeTrap.new()
    linked_trap.configure(TrapCatalog.definition(&"frost_sigil"))
    game._configure_trap(linked_trap)
    assert(linked_trap.damage > 15)
    assert(is_equal_approx(linked_trap.effect_duration, 2.4 * 1.4))
    assert(is_equal_approx(game._monster_respawn_delay(3.0), 3.0 / 1.66))
    assert(is_equal_approx(game._monster_damage_multiplier(), 1.25))
    assert(is_equal_approx(game._monster_health_multiplier(), 1.2))
    game.village_modifiers = previous_modifiers
    root.remove_child(game)
    game.free()
    print("V0.6 content wiring test passed")
    quit(0)
