extends SceneTree

const CollectibleRouteScript := preload("res://scripts/core/collectible_route.gd")

func _check(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error("CollectibleRoute test failed: %s" % message)
    quit(1)
    return false

func _init() -> void:
    var route: CollectibleRoute = CollectibleRouteScript.new()
    var cells: Array[Vector2i] = [Vector2i(2, 2), Vector2i(8, 1), Vector2i(4, 6)]
    route.setup(cells)

    if not _check(route.get_remaining_count() == 3, "initial count mismatch"):
        return
    if not _check(not route.can_enter_treasure(), "treasure unlocked too early"):
        return
    if not _check(route.get_next_target(Vector2i.ZERO) == Vector2i(2, 2), "nearest target mismatch"):
        return
    if not _check(route.collect_at(Vector2i(2, 2)), "first collectible not collected"):
        return
    if not _check(not route.collect_at(Vector2i(2, 2)), "collectible collected twice"):
        return
    if not _check(route.collected_count == 1, "collected count mismatch"):
        return

    route.collect_at(Vector2i(8, 1))
    route.collect_at(Vector2i(4, 6))
    if not _check(route.can_enter_treasure(), "treasure remains locked"):
        return
    if not _check(route.get_remaining_count() == 0, "remaining collectibles mismatch"):
        return

    print("CollectibleRoute test passed")
    quit(0)
