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

    # place walls across the middle row except the door so path must go through DOOR when open
    for x in range(1, 14):
        var cell := Vector2i(x, 5)
        if cell == DOOR:
            continue
        astar.set_point_solid(cell, true)

    # Open door -> path should include DOOR
    astar.set_point_solid(DOOR, false)
    var path_open := astar.get_id_path(ENTRANCE, TREASURE)
    var passes_door := false
    for p in path_open:
        if Vector2i(p) == DOOR:
            passes_door = true
            break
    if not _check(passes_door, "path should pass through the door when open"):
        return

    # Close door -> path should be blocked (empty or not passing door)
    astar.set_point_solid(DOOR, true)
    var path_closed := astar.get_id_path(ENTRANCE, TREASURE)
    var passes_door_closed := false
    for p in path_closed:
        if Vector2i(p) == DOOR:
            passes_door_closed = true
            break
    if not _check(not passes_door_closed and path_closed.size() == 0, "path should be blocked when door closed"):
        return

    print("Door blocking test passed")
    quit(0)
