extends SceneTree

func _init() -> void:
    assert(GameVersion.VALUE == "v0.8.0-alpha")
    assert(GameVersion.SAVE_VERSION == 6)
    var migrated := SaveMigrator.new().migrate({"version": 4, "resources": {"gold": 42}, "discoveries": {"ghost": true}})
    assert(int(migrated.version) == 6)
    for field in ["campaign_v08", "nemesis", "blueprints", "village_quests", "accessibility_v08", "prisoners_v08", "patrols_v08", "last_replay_v08", "custom_challenge_v08", "guided_campaign_v08", "formations_v08", "rescue_v08", "last_debrief_v08", "localization_v08", "difficulty_v08"]:
        assert(migrated.has(field))
    assert(int(migrated.resources.gold) == 42 and bool(migrated.discoveries.ghost))
    print("v0.8 release readiness test passed")
    quit()
