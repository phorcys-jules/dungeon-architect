extends SceneTree

func _init() -> void:
    assert(GameVersion.VALUE == "v0.8.0-alpha")
    assert(GameVersion.SAVE_VERSION == 5)
    var migrated := SaveMigrator.new().migrate({"version": 4, "resources": {"gold": 42}, "discoveries": {"ghost": true}})
    assert(int(migrated.version) == 5)
    for field in ["campaign_v08", "nemesis", "blueprints", "village_quests", "accessibility_v08"]:
        assert(migrated.has(field))
    assert(int(migrated.resources.gold) == 42 and bool(migrated.discoveries.ghost))
    print("v0.8 release readiness test passed")
    quit()
