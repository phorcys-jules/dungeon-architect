extends SceneTree

func _check(c, m):
    if c:
        return true
    push_error("level validator failed: %s" % m)
    quit(1)
    return false

func _init() -> void:
    var validator := LevelValidator.new()
    var entrance := Vector2i(0, 5)
    var treasure := Vector2i(14, 5)
    var grid_size := Vector2i(15, 10)
    var walls := []

    # Build a vertical barrier separating entrance and treasure,
    # with a single opening at y = 5 acting as the door.
    for y in range(grid_size.y):
        if y == 5:
            continue
        walls.append(Vector2i(7, y))

    var solvable := validator.is_level_solvable(entrance, treasure, grid_size, walls)
    if not _check(solvable, "level should be solvable when door open"):
        return

    # Close the only opening in the barrier.
    walls.append(Vector2i(7, 5))
    var blocked := validator.is_level_solvable(entrance, treasure, grid_size, walls)
    if not _check(not blocked, "level should be unsolvable when door blocked"):
        return

    print("Level validator test passed")
    quit(0)
