extends SceneTree

func _init() -> void:
    var ghost: MonsterArchetypeData = load("res://resources/monsters/ghost.tres")
    var mimic: MonsterArchetypeData = load("res://resources/monsters/mimic.tres")
    var walls: Array[Vector2i] = [Vector2i(2, 1)]
    assert(MonsterTacticalRuntime.phase_destination(Vector2i(1, 1), Vector2i(5, 1), walls, Vector2i(8, 8)) == Vector2i(3, 1))
    assert(MonsterTacticalRuntime.phase_destination(Vector2i(1, 1), Vector2i(1, 5), walls, Vector2i(8, 8)) == Vector2i(1, 1))
    assert(MonsterTacticalRuntime.collision_damage(ghost, true) == ghost.base_damage)
    assert(MonsterTacticalRuntime.collision_damage(mimic, true) > mimic.base_damage)
    assert(MonsterTacticalRuntime.collision_damage(mimic, false) == mimic.base_damage)
    assert(is_equal_approx(MonsterTacticalRuntime.movement_multiplier(true, false, 0.72, 0.58), 0.72))
    assert(is_equal_approx(MonsterTacticalRuntime.movement_multiplier(false, true, 0.72, 0.58), 0.58))
    print("Monster tactical runtime test passed")
    quit(0)
