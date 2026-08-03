extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

func _init() -> void:
    var game := MainScene.instantiate()
    root.add_child(game)
    await process_frame

    game.game_state = game.GameState.WAVE_RESULT
    game.waves.current_wave = 2
    game._offer_run_choices()
    assert(game.pending_run_choice)
    assert(game.current_choice_offer.size() == 3)
    assert(game.choice_buttons.filter(func(button: Button): return button.visible).size() == 3)
    assert(game.start_button.disabled)
    assert(game.result_summary.position.y + game.result_summary.size.y <= game.choice_buttons[0].position.y)

    var selected: Dictionary = game.current_choice_offer[0]
    game._select_run_choice(0)
    assert(not game.pending_run_choice)
    assert(game.run_build_state.selected_choice_ids.has(StringName(selected.id)))
    assert(not game.start_button.disabled)
    assert(game.choice_buttons[0].text.begins_with("✓"))
    assert(game.effect_rows.any(func(row: Button): return row.text == String(selected.label)))

    for key: Variant in selected.get("modifiers", {}).keys():
        assert(is_equal_approx(float(game.run_build_state.modifiers[key]), float(selected.modifiers[key])))
    for tag: Variant in selected.get("tags", []):
        assert(game.v06_integration.run_tags.has("room:%s" % String(tag)))

    game.waves.current_wave = 3
    game._offer_run_choices()
    assert(game.current_choice_offer.all(func(choice: Dictionary): return StringName(choice.id) != StringName(selected.id)))

    print("Run choice integration test passed")
    quit(0)
