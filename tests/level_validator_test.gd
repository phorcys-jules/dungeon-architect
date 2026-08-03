extends SceneTree

func _check(c, m):
    if c: return true
    push_error("level validator failed: %s" % m)
    quit(1)
    return false

func _init() -> void:
    var validator := LevelValidator.new()
    var entrance := Vector2i(0,5)
    var treasure := Vector2i(14,5)
    var grid_size := Vector2i(15,10)
    var walls := []
    # put walls across middle row but leave door at x=7
    for x in range(1,14):
        if x == 7:
            continue
        walls.append(Vector2i(x,5))
    var solvable := validator.is_level_solvable(entrance, treasure, grid_size, walls)
    if not _check(solvable, "level should be solvable when door open"):
        return
    # add wall at door -> unsolvable
    walls.append(Vector2i(7,5))
    var solvable2 := validator.is_level_solvable(entrance, treasure, grid_size, walls)
    if not _check(not solvable2, "level should be unsolvable when door blocked"):
        return
    print("Level validator test passed")
    quit(0)
