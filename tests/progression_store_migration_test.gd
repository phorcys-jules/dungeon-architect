extends SceneTree

func _init() -> void:
    var path := "user://progression_store_migration_test.json"
    var store := V06ProgressionStore.new(path)
    store.delete_save()
    var file := FileAccess.open(path, FileAccess.WRITE)
    assert(file != null)
    file.store_string(JSON.stringify({
        "version": V06ProgressionStore.SAVE_VERSION,
        "state": {
            "version": 3,
            "resources": {"gold": 42, "essence": 7, "stone": 0, "bones": 0},
            "unlocks": ["trap_damage"],
            "tutorial": {"completed": ["prepare_dungeon"]},
            "run_history": [{"victory": true}],
        },
    }))
    file.close()

    var migrated := store.load_state()
    assert(int(migrated.version) == GameVersion.SAVE_VERSION)
    assert(int(migrated.unlock_economy.resources.gold) == 42)
    assert(bool(migrated.unlock_economy.unlocked.trap_damage))
    assert(migrated.tutorial_progress.completed == ["prepare_dungeon"])
    assert(migrated.run_history.size() == 1)

    assert(store.save_state(migrated))
    assert(int(store.load_state().version) == GameVersion.SAVE_VERSION)
    store.delete_save()
    print("Progression store migration test passed")
    quit(0)
