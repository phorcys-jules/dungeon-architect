extends SceneTree

func _init() -> void:
    var runtime := DungeonBuildRuntime.new()
    runtime.configure(
        Vector2i(15, 10),
        8,
        [Vector2i(5, 5)],
        Vector2i(0, 5),
        Vector2i(14, 5),
        [Vector2i(7, 5)]
    )
    runtime.configure_default_passages()

    assert(runtime.remaining_wall_budget() == 8)
    assert(runtime.secret_passages.passages.size() == 2)

    var place_result: Dictionary = runtime.try_place_wall(Vector2i(1, 1), 100)
    assert(bool(place_result.get("ok", false)))
    assert(runtime.blocked_cells().has(Vector2i(1, 1)))

    var remove_result: Dictionary = runtime.try_remove_wall(Vector2i(1, 1))
    assert(bool(remove_result.get("ok", false)))
    assert(not runtime.blocked_cells().has(Vector2i(1, 1)))

    assert(runtime.resolve_monster_passage(Vector2i(3, 3), ["ghost"]) == Vector2i(11, 7))
    assert(runtime.resolve_monster_passage(Vector2i(3, 3), ["guardian"]) == Vector2i(3, 3))

    print("dungeon build gameplay test passed")
    quit()
