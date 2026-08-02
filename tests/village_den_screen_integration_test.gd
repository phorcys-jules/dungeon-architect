extends SceneTree

const DenScreenScene := preload("res://scenes/village_den_screen.tscn")
const VillageSaveStoreScript := preload("res://scripts/village/village_save_store.gd")

func _init() -> void:
    var path := "user://village_den_screen_test.json"
    var store: VillageSaveStore = VillageSaveStoreScript.new(path)
    store.delete_save()

    var den := DenProgression.new()
    den.add_resources(40)
    if not store.save_den(den):
        quit(1)
        return

    var screen := DenScreenScene.instantiate()
    screen.set_save_store(store)
    root.add_child(screen)
    await process_frame

    if screen.view_model.den.stored_resources != 40:
        store.delete_save()
        quit(1)
        return

    screen._on_upgrade_pressed()
    var restored := store.load_den()
    if restored.level != 1 or restored.stored_resources != 0:
        store.delete_save()
        quit(1)
        return

    screen.queue_free()
    store.delete_save()
    print("Village den screen integration test passed")
    quit(0)
