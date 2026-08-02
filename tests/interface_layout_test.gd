extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

func _init() -> void:
    var game := MainScene.instantiate()
    root.add_child(game)
    await process_frame

    _assert_no_overlap(game.phase_label, game.countdown_label)
    _assert_no_overlap(game.countdown_label, game.wave_label)
    _assert_no_overlap(game.wave_label, game.gold_label)
    _assert_no_overlap(game.gold_label, game.start_button)
    _assert_no_overlap(game.intelligence_label, game.objectives_label)
    _assert_no_overlap(game.objectives_label, game.modifiers_label)
    _assert_no_overlap(game.objectives_label, game.modifiers_scroll)
    _assert_no_overlap(game.modifiers_scroll, game.shortcut_title)
    _assert_inside_viewport(game.intelligence_label)
    _assert_inside_viewport(game.wall_button)
    _assert_inside_viewport(game.remove_wall_button)
    _assert_no_overlap(game.modifiers_label, game.trap_button)
    _assert_no_overlap(game.trap_button, game.defender_button)
    _assert_no_overlap(game.defender_button, game.door_button)
    _assert_no_overlap(game.result_summary, game.village_button)
    _assert_no_overlap(game.result_summary, game.restart_button)
    _assert_no_overlap(game.village_button, game.restart_button)

    assert(game.result_summary.scroll_active)
    assert(game.status_label.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS)
    assert(game.result_panel.size.y >= 450.0)
    assert(not game.effect_rows.is_empty())
    for row: Button in game.effect_rows:
        assert(not row.tooltip_text.is_empty())
    print("Interface layout test passed")
    quit(0)

func _assert_no_overlap(first: Control, second: Control) -> void:
    var first_rect := Rect2(first.position, first.size)
    var second_rect := Rect2(second.position, second.size)
    assert(not first_rect.intersects(second_rect), "%s overlaps %s" % [first.name, second.name])

func _assert_inside_viewport(control: Control) -> void:
    var viewport_rect := Rect2(Vector2.ZERO, Vector2(960, 640))
    assert(viewport_rect.encloses(Rect2(control.position, control.size)), "%s is outside the viewport" % control.name)
