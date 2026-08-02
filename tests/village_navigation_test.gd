extends SceneTree

const VillageScene := preload("res://scenes/village_v03_screen.tscn")

func _init() -> void:
    var screen := VillageScene.instantiate()
    root.add_child(screen)
    await process_frame
    if screen.start_run_button == null:
        quit(1)
        return
    screen.transition_in_progress = true
    screen._refresh_navigation()
    if not screen.start_run_button.disabled:
        quit(1)
        return
    print("Village navigation test passed")
    quit(0)
