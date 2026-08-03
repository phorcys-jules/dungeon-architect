extends SceneTree

func _check(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error("Accessibility bindings test failed: %s" % message)
    quit(1)
    return false

func _init() -> void:
    var profile := AccessibilityProfile.new()
    profile.ensure_default_bindings()
    # Ensure core bindings exist and map to integer keycodes
    if not _check(profile.bindings.has(&"toggle_door"), "toggle_door binding present"):
        return
    if not _check(profile.bindings.has(&"start_wave"), "start_wave binding present"):
        return
    if not _check(int(profile.bindings[&"toggle_door"]) > 0, "toggle_door has positive keycode"):
        return
    print("Accessibility bindings test passed")
    quit(0)
