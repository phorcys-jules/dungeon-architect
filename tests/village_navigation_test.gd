extends SceneTree

const VillageScene := preload("res://scenes/village_screen.tscn")

# Release-blocking coverage for the village → run transition.
func _init() -> void:
    var den_path := "user://village_map_den_test.json"
    var meta_path := "user://village_map_meta_test.json"
    var den_store := VillageSaveStore.new(den_path)
    var meta_store := V06ProgressionStore.new(meta_path)
    den_store.delete_save()
    meta_store.delete_save()
    var den := DenProgression.new()
    den.add_soul_shards(200)
    assert(den_store.save_den(den))
    var screen := VillageScene.instantiate()
    screen.set_save_store(den_store)
    screen.meta_store = meta_store
    root.add_child(screen)
    await process_frame
    if screen.start_run_button == null:
        quit(1)
        return
    if screen.music_player == null or screen.music_player.stream == null or not screen.music_player.playing:
        quit(1)
        return
    if (screen.music_player.stream as AudioStreamWAV).loop_mode != AudioStreamWAV.LOOP_FORWARD:
        quit(1)
        return
    if screen.ambient_animator == null or screen.ambient_animator.TORCH_POSITIONS.size() != 12:
        quit(1)
        return
    var animation_time: float = screen.ambient_animator.elapsed
    screen.ambient_animator._process(0.1)
    if screen.ambient_animator.elapsed <= animation_time:
        quit(1)
        return
    screen.transition_in_progress = true
    screen._refresh_navigation()
    if not screen.start_run_button.disabled:
        quit(1)
        return
    if screen.building_buttons.size() != 5:
        quit(1)
        return
    if screen.archives_button == null or screen.archives_panel == null or screen.archives_text == null:
        quit(1)
        return
    screen._open_archives()
    if not screen.archives_panel.visible or screen.archives_text.text.is_empty():
        quit(1)
        return
    screen.archives_panel.visible = false
    for building_button: Button in screen.building_buttons.values():
        var artwork := building_button.get_node_or_null("Artwork") as TextureRect
        if artwork == null or artwork.texture == null:
            quit(1)
            return
        if building_button.get_node_or_null("ProgressBadge") == null:
            quit(1)
            return
    if screen.village_residents.size() < 7 or screen.reaction_label == null:
        quit(1)
        return
    if screen.feedback_button == null or screen.feedback_panel == null:
        quit(1)
        return
    screen._set_feedback_option("music_volume", 0.35)
    if not is_equal_approx(float(meta_store.load_state().feedback_settings.music_volume), 0.35):
        quit(1)
        return
    screen.transition_in_progress = false
    screen._select_building("forge")
    if not String(screen.title_label.text).contains("Forge"):
        quit(1)
        return
    screen._on_upgrade_pressed()
    if int(screen.progression_service.state.buildings.forge) != 1:
        quit(1)
        return
    if den_store.load_den().soul_shards != 140:
        quit(1)
        return
    if not String(screen.status_label.text).contains("Fosse de poix"):
        quit(1)
        return
    if not String((screen.building_buttons.forge as Button).get_node("ProgressBadge").text).contains("1"):
        quit(1)
        return
    den_store.delete_save()
    meta_store.delete_save()
    print("Village navigation test passed")
    quit(0)
