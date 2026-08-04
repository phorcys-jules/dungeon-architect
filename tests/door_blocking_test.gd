extends SceneTree

func _check(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error("Door blocking test failed: %s" % message)
    quit(1)
    return false

func _init() -> void:
    var astar := AStarGrid2D.new()
    var grid_size := Vector2i(15, 10)
    var cell_size := 48
    var entrance := Vector2i(0, 5)
    var treasure := Vector2i(14, 5)
    var door := Vector2i(7, 5)

    astar.region = Rect2i(Vector2i.ZERO, grid_size)
    astar.cell_size = Vector2(cell_size, cell_size)
    astar.offset = Vector2(cell_size / 2.0, cell_size / 2.0)
    astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    astar.update()

    # Place walls across the middle row except the door so the path must use it.
    for x in range(1, 14):
        var cell := Vector2i(x, 5)
        if cell == door:
            continue
        astar.set_point_solid(cell, true)

    # Open door: the path should include the door cell.
    astar.set_point_solid(door, false)
    var path_open := astar.get_id_path(entrance, treasure)
    var passes_door := false
    for point in path_open:
        if Vector2i(point) == door:
            passes_door = true
            break
    if not _check(passes_door, "path should pass through the door when open"):
        return

    # Closed door: no route should remain through the wall.
    astar.set_point_solid(door, true)
    var path_closed := astar.get_id_path(entrance, treasure)
    var passes_closed_door := false
    for point in path_closed:
        if Vector2i(point) == door:
            passes_closed_door = true
            break
    if not _check(not passes_closed_door and path_closed.is_empty(), "path should be blocked when door closed"):
        return

    print("Door blocking test passed")
    quit(0)
