extends SceneTree

func _init() -> void:
    var runtime := LocalizationRuntime.new()
    var audit := runtime.audit_catalogs()
    assert(int(audit.messages) >= 60)
    assert(Array(audit.missing).is_empty())
    assert(Array(audit.placeholder_mismatches).is_empty())
    assert(runtime.set_locale(&"en"))
    assert(TranslationServer.translate("Nouvelle run") == "New run")
    assert(TranslationServer.translate("Aventurier : %d / %d PV") == "Adventurer: %d / %d HP")
    assert(runtime.text("tutorial.choose_route") == "Choose a campaign route.")
    assert(runtime.set_locale(&"fr"))
    assert(TranslationServer.translate("Nouvelle run") == "Nouvelle run")
    var source_files := [
        "res://scripts/main.gd",
        "res://scripts/game_controller.gd",
        "res://scripts/village/village_screen.gd",
    ]
    for path in source_files:
        var content := FileAccess.get_file_as_string(path)
        assert(not content.is_empty())
        if path.ends_with("main.gd"):
            assert(content.contains("tr(\"Or : %d\") % current_gold"))
        elif path.ends_with("game_controller.gd"):
            assert(content.contains("tr(\"OBJECTIFS\\n%s\")"))
        else:
            assert(content.contains("tr(\"Langue : %s\")"))
    print("v0.8 localization coverage test passed: %d messages" % int(audit.messages))
    quit()
