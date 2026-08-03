extends SceneTree

func _init() -> void:
    assert(GameVersion.VALUE == "v0.7.0-alpha")
    assert(GameVersion.SAVE_VERSION == SaveMigrator.CURRENT_VERSION)
    var previous := {"version": 4, "resources": {"gold": 42}, "run_history": [{"victory": true}], "tutorial": {"completed": ["prepare_dungeon"]}, "discoveries": {"ghost": true}}
    var migrated := SaveMigrator.new().migrate(previous)
    assert(int(migrated.version) == GameVersion.SAVE_VERSION)
    assert(int(migrated.resources.gold) == 42)
    assert(migrated.run_history.size() == 1)
    assert(bool(migrated.discoveries.ghost))
    print("v0.7 release readiness test passed")
    quit()
