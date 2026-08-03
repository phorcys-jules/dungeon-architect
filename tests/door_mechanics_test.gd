extends SceneTree

func _check(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error("Door mechanics test failed: %s" % message)
    quit(1)
    return false

func _init() -> void:
    var rules := PacmanLoopRules.new()
    # Ensure initial toggle works
    if not _check(rules.consume_door_toggle(), "first door toggle"):
        return
    # Immediately consuming again should fail due to cooldown
    if not _check(not rules.consume_door_toggle(), "door cooldown enforces single toggle"):
        return
    # Advance time beyond cooldown and ensure toggle is available again
    rules.tick(rules.door_cooldown + 0.5)
    if not _check(rules.can_toggle_door(), "door cooldown expiry"):
        return
    print("Door mechanics test passed")
    quit(0)
