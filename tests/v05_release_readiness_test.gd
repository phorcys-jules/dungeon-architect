extends SceneTree

func _fail(message: String) -> void:
    push_error(message)
    quit(1)

func _init() -> void:
    if GameVersion.VALUE != "v0.5.0-alpha" or GameVersion.SAVE_VERSION != 3:
        _fail("Invalid v0.5 version metadata")
        return

    var settings := GameFeedbackSettings.new()
    settings.apply({"effects_volume": 2.0, "reduced_motion": true})
    var feedback := FeedbackEventCatalog.new().event("critical", settings)
    if float(feedback.effects_volume) != 1.0 or float(feedback.shake) != 0.0:
        _fail("Feedback accessibility settings are not applied")
        return

    var tutorial := TutorialProgress.new()
    for step in TutorialProgress.STEPS:
        if not tutorial.complete(step):
            _fail("Tutorial step rejected: %s" % step)
            return
    if not tutorial.is_complete():
        _fail("Tutorial did not complete")
        return

    var migrated := SaveMigrator.new().migrate({"version": 2, "resources": {"gold": 42}, "unlocks": ["ghost"]})
    if int(migrated.version) != 3 or int(migrated.resources.gold) != 42 or not migrated.has("run_history"):
        _fail("v0.4 save migration lost data")
        return

    print("v0.5 release readiness test passed")
    quit(0)
