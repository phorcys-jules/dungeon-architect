extends SceneTree

const MobileMonsterScript := preload("res://scripts/monsters/mobile_monster.gd")

func _check(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error("MobileMonster test failed: %s" % message)
    quit(1)
    return false

func _init() -> void:
    var monster: MobileMonster = MobileMonsterScript.new()
    monster.setup(Vector2i(1, 1), 100.0)
    monster.world_position = Vector2(48, 48)
    monster.set_path([Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)])

    if not _check(monster.has_path(), "path not assigned"):
        return
    if not _check(monster.get_target_cell() == Vector2i(2, 1), "first target mismatch"):
        return

    var safety := 0
    while monster.has_path() and safety < 100:
        monster.tick_grid(0.1, 48.0)
        safety += 1

    if not _check(safety < 100, "movement did not terminate"):
        return
    if not _check(monster.cell == Vector2i(2, 2), "final cell mismatch"):
        return

    monster.reset_to_home(48.0)
    if not _check(monster.cell == Vector2i(1, 1), "home reset mismatch"):
        return
    if not _check(not monster.has_path(), "path remains after reset"):
        return

    print("MobileMonster test passed")
    quit(0)
