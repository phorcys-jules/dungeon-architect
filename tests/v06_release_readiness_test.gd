extends SceneTree

func _fail(message: String) -> void:
    push_error(message)
    quit(1)

func _init() -> void:
    if GameVersion.VALUE != "v0.6.0-alpha" or GameVersion.SAVE_VERSION != 4:
        _fail("Invalid v0.6 version metadata")
        return

    var legacy_payload := {
        "version": 3,
        "resources": {"gold": 42, "essence": 7},
        "unlocks": ["ghost"],
        "run_history": [{"victory": true}],
        "tutorial": {"completed": ["welcome"]},
    }
    var migrated := SaveMigrator.new().migrate(legacy_payload)
    if int(migrated.version) != 4:
        _fail("v0.5 save was not migrated to version 4")
        return
    if int(migrated.resources.gold) != 42 or migrated.unlocks != ["ghost"]:
        _fail("v0.5 progression was lost during migration")
        return
    if migrated.run_history.size() != 1 or migrated.tutorial.completed != ["welcome"]:
        _fail("v0.5 run history or tutorial progress was lost")
        return
    for field in ["discoveries", "achievements", "global_stats", "completed_challenges", "black_market"]:
        if not migrated.has(field):
            _fail("Missing v0.6 save field: %s" % field)
            return

    var current_payload := migrated.duplicate(true)
    current_payload.discoveries = {"monster:ghost": "discovered"}
    current_payload.completed_challenges = ["no_traps"]
    var round_trip := SaveMigrator.new().migrate(current_payload)
    if round_trip.discoveries != current_payload.discoveries or round_trip.completed_challenges != ["no_traps"]:
        _fail("v0.6 progression is not preserved")
        return

    print("v0.6 release readiness test passed")
    quit(0)
