extends SceneTree

func _check(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error("Pacman loop rules test failed: %s" % message)
    quit(1)
    return false

func _init() -> void:
    var rules := PacmanLoopRules.new()
    if not _check(rules.get_target(PacmanLoopRules.Behaviour.CHASER, Vector2i(4, 4), Vector2i.RIGHT, Vector2i(9, 9), Vector2i.ZERO) == Vector2i(4, 4), "chaser target"):
        return
    if not _check(rules.get_target(PacmanLoopRules.Behaviour.AMBUSHER, Vector2i(4, 4), Vector2i.RIGHT, Vector2i(9, 9), Vector2i.ZERO) == Vector2i(7, 4), "ambusher target"):
        return
    rules.activate_panic()
    if not _check(rules.is_panicking(), "panic activation"):
        return
    rules.tick(7.0)
    if not _check(not rules.is_panicking(), "panic expiry"):
        return
    if not _check(rules.consume_door_toggle(), "first door toggle"):
        return
    if not _check(not rules.consume_door_toggle(), "door cooldown"):
        return
    rules.tick(3.0)
    if not _check(rules.can_toggle_door(), "door cooldown expiry"):
        return
    var monsters: Array[Vector2i] = [Vector2i(4, 3), Vector2i(4, 5)]
    var blocked: Array[Vector2i] = [Vector2i(3, 4), Vector2i(5, 4)]
    if not _check(rules.is_captured(Vector2i(4, 4), monsters, blocked), "capture detection"):
        return
    print("Pac-Man loop rules test passed")
    quit(0)
