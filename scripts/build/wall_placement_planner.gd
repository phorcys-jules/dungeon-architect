class_name WallPlacementPlanner
extends RefCounted

var grid_size := Vector2i(15, 10)
var wall_budget := 8
var placed_walls: Array[Vector2i] = []

func configure(size: Vector2i, budget: int) -> void:
    grid_size = Vector2i(maxi(size.x, 1), maxi(size.y, 1))
    wall_budget = maxi(budget, 0)
    placed_walls.clear()

func can_place(cell: Vector2i, fixed_walls: Array[Vector2i], entrance: Vector2i, objective: Vector2i, reserved: Array[Vector2i] = []) -> bool:
    if placed_walls.size() >= wall_budget:
        return false
    if not _inside(cell) or cell == entrance or cell == objective:
        return false
    if fixed_walls.has(cell) or placed_walls.has(cell) or reserved.has(cell):
        return false
    var candidate := fixed_walls.duplicate()
    candidate.append_array(placed_walls)
    candidate.append(cell)
    return _has_route(entrance, objective, candidate)

func place(cell: Vector2i, fixed_walls: Array[Vector2i], entrance: Vector2i, objective: Vector2i, reserved: Array[Vector2i] = []) -> bool:
    if not can_place(cell, fixed_walls, entrance, objective, reserved):
        return false
    placed_walls.append(cell)
    return true

func remove(cell: Vector2i) -> bool:
    var index := placed_walls.find(cell)
    if index < 0:
        return false
    placed_walls.remove_at(index)
    return true

func remaining_budget() -> int:
    return maxi(wall_budget - placed_walls.size(), 0)

func build_blocked_cells(fixed_walls: Array[Vector2i]) -> Array[Vector2i]:
    var result := fixed_walls.duplicate()
    for cell in placed_walls:
        if not result.has(cell):
            result.append(cell)
    return result

func _has_route(start: Vector2i, goal: Vector2i, blocked: Array[Vector2i]) -> bool:
    if blocked.has(start) or blocked.has(goal):
        return false
    var queue: Array[Vector2i] = [start]
    var visited := {start: true}
    var directions: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
    var cursor := 0
    while cursor < queue.size():
        var current := queue[cursor]
        cursor += 1
        if current == goal:
            return true
        for direction in directions:
            var next := current + direction
            if _inside(next) and not blocked.has(next) and not visited.has(next):
                visited[next] = true
                queue.append(next)
    return false

func _inside(cell: Vector2i) -> bool:
    return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size.x and cell.y < grid_size.y
