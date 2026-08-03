class_name LevelValidator
extends RefCounted

# Simple validator: ensure there's a path from ENTRANCE to TREASURE given walls

func is_level_solvable(entrance: Vector2i, treasure: Vector2i, grid_size: Vector2i, walls: Array) -> bool:
    var astar := AStarGrid2D.new()
    astar.region = Rect2i(Vector2i.ZERO, grid_size)
    astar.cell_size = Vector2(48, 48)
    astar.offset = Vector2(24, 24)
    astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    for wall in walls:
        astar.set_point_solid(wall, true)
    astar.update()
    var path := astar.get_id_path(entrance, treasure)
    return not path.empty()
