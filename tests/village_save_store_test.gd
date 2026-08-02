extends SceneTree

const DenProgressionScript := preload("res://scripts/village/den_progression.gd")
const VillageSaveStoreScript := preload("res://scripts/village/village_save_store.gd")

func _init() -> void:
    var path := "user://village_save_test.json"
    var store: VillageSaveStore = VillageSaveStoreScript.new(path)
    store.delete_save()

    var den: DenProgression = DenProgressionScript.new()
    den.add_resources(150)
    if not den.upgrade():
        quit(1)
        return
    den.add_resources(25)

    if not store.save_den(den):
        quit(1)
        return

    var restored := store.load_den()
    if restored.level != den.level or restored.stored_resources != den.stored_resources:
        quit(1)
        return

    if not store.delete_save() or FileAccess.file_exists(path):
        quit(1)
        return

    print("Village save persistence test passed")
    quit(0)
