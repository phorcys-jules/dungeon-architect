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

    monster.world_position = Vector2(4, 1) * 48.0
    monster.cell = Vector2i(4, 1)
    monster.take_damage(monster.current_health, 0.2)
    if not _check(monster.returning_home, "defeated monster is not returning to the lair"):
        return
    safety = 0
    while not monster.is_active() and safety < 100:
        monster.tick_respawn(0.1, 48.0)
        safety += 1
    if not _check(monster.is_active() and monster.cell == monster.home_cell, "monster did not revive from its lair"):
        return

    monster.hold_at_home(0.5, 48.0)
    if not _check(not monster.is_active(), "release order delay is not respected"):
        return
    monster.tick_respawn(0.5, 48.0)
    if not _check(monster.is_active(), "monster was not released from its lair"):
        return

    print("MobileMonster test passed")
    quit(0)
