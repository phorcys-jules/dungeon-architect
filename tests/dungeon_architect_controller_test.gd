extends SceneTree

func _init() -> void:
    var controller_script := load("res://scripts/dungeon_architect_controller.gd")
    assert(controller_script != null)

    var controller = controller_script.new()
    controller._build_level()
    assert(controller.dungeon_build.remaining_wall_budget() == 8)
    assert(controller.dungeon_build.secret_passages.passages.size() == 2)

    var place_result: Dictionary = controller.dungeon_build.try_place_wall(Vector2i(1, 1), 100)
    assert(place_result.ok)
    assert(controller.dungeon_build.blocked_cells().has(Vector2i(1, 1)))

    var remove_result: Dictionary = controller.dungeon_build.try_remove_wall(Vector2i(1, 1))
    assert(remove_result.ok)
    assert(not controller.dungeon_build.blocked_cells().has(Vector2i(1, 1)))

    assert(controller.dungeon_build.resolve_monster_passage(Vector2i(3, 3), ["ghost"]) == Vector2i(11, 7))
    assert(controller.dungeon_build.resolve_monster_passage(Vector2i(3, 3), ["guardian"]) == Vector2i(3, 3))

    print("dungeon architect controller test passed")
    controller.free()
    quit()
