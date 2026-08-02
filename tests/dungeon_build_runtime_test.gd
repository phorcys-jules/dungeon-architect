extends SceneTree

func _init() -> void:
    var runtime := DungeonBuildRuntime.new()
    var base_walls: Array[Vector2i] = []
    runtime.configure(Vector2i(5, 3), 2, base_walls, Vector2i(0, 1), Vector2i(4, 1), [Vector2i(2, 0)])

    var no_gold := runtime.try_place_wall(Vector2i(1, 0), 0)
    assert(not no_gold.ok)
    assert(no_gold.reason == "not_enough_gold")

    var first := runtime.try_place_wall(Vector2i(1, 0), 100)
    assert(first.ok)
    assert(first.gold_delta == -DungeonBuildRuntime.WALL_COST)
    assert(runtime.remaining_wall_budget() == 1)

    var second := runtime.try_place_wall(Vector2i(1, 2), 100)
    assert(second.ok)
    assert(runtime.remaining_wall_budget() == 0)

    var over_budget := runtime.try_place_wall(Vector2i(3, 0), 100)
    assert(not over_budget.ok)

    var removed := runtime.try_remove_wall(Vector2i(1, 2))
    assert(removed.ok)
    assert(removed.gold_delta == DungeonBuildRuntime.WALL_REFUND)

    runtime.configure_default_passages()
    assert(runtime.resolve_monster_passage(Vector2i(3, 3), ["ghost"]) == Vector2i(11, 7))
    assert(runtime.resolve_monster_passage(Vector2i(3, 3), ["slime"]) == Vector2i(3, 3))

    print("dungeon build runtime test passed")
    quit(0)
