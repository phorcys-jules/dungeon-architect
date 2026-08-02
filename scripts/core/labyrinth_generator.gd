class_name LabyrinthGenerator
extends RefCounted

const CARDINAL_DIRECTIONS: Array[Vector2i] = [
    Vector2i.RIGHT,
    Vector2i.DOWN,
    Vector2i.LEFT,
    Vector2i.UP,
]

var size := Vector2i(15, 10)
var entrance := Vector2i(0, 5)
var treasure := Vector2i(14, 5)
var minimum_loops := 4
var wall_density := 0.34

func generate(seed_value: int, required_cells: Array[Vector2i] = []) -> Dictionary:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value

    var protected: Dictionary = {}
    protected[entrance] = true
    protected[treasure] = true
    for cell: Vector2i in required_cells:
        protected[cell] = true

    var open_cells := _carve_spanning_maze(rng)
    _open_required_routes(open_cells, required_cells)
    _add_loops(open_cells, rng)

    var walls: Array[Vector2i] = []
    for y: int in range(size.y):
        for x: int in range(size.x):
            var cell := Vector2i(x, y)
            if not open_cells.has(cell) and not protected.has(cell):
                walls.append(cell)

    return {
        "seed": seed_value,
        "size": size,
        "walls": walls,
        "open_cells": open_cells.keys(),
        "required_cells": required_cells.duplicate(),
    }

func is_valid(layout: Dictionary, required_cells: Array[Vector2i] = []) -> bool:
    var walls: Array[Vector2i] = []
    walls.assign(layout.get("walls", []))
    var blocked: Dictionary = {}
    for wall: Vector2i in walls:
        blocked[wall] = true

    if blocked.has(entrance) or blocked.has(treasure):
        return false

    var targets: Array[Vector2i] = required_cells.duplicate()
    targets.append(treasure)
    var current := entrance
    for target: Vector2i in targets:
        if not _has_path(current, target, blocked):
            return false
        current = target
    return true

func fingerprint(layout: Dictionary) -> String:
    var walls: Array[Vector2i] = []
    walls.assign(layout.get("walls", []))
    walls.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
    var values: PackedStringArray = []
    for wall: Vector2i in walls:
        values.append("%d:%d" % [wall.x, wall.y])
    return ";".join(values)

func _carve_spanning_maze(rng: RandomNumberGenerator) -> Dictionary:
    var open_cells: Dictionary = {}
    var stack: Array[Vector2i] = [entrance]
    open_cells[entrance] = true

    while not stack.is_empty():
        var current: Vector2i = stack.back()
        var candidates: Array[Vector2i] = []
        for direction: Vector2i in CARDINAL_DIRECTIONS:
            var next_cell: Vector2i = current + direction
            if _inside(next_cell) and not open_cells.has(next_cell):
                candidates.append(next_cell)

        if candidates.is_empty():
            stack.pop_back()
            continue

        var chosen: Vector2i = candidates[rng.randi_range(0, candidates.size() - 1)]
        open_cells[chosen] = true
        stack.append(chosen)

        if float(open_cells.size()) / float(size.x * size.y) >= 1.0 - wall_density:
            break

    return open_cells

func _open_required_routes(open_cells: Dictionary, required_cells: Array[Vector2i]) -> void:
    var current := entrance
    var targets: Array[Vector2i] = required_cells.duplicate()
    targets.append(treasure)
    for target: Vector2i in targets:
        var cursor := current
        while cursor.x != target.x:
            cursor.x += 1 if target.x > cursor.x else -1
            open_cells[cursor] = true
        while cursor.y != target.y:
            cursor.y += 1 if target.y > cursor.y else -1
            open_cells[cursor] = true
        current = target

func _add_loops(open_cells: Dictionary, rng: RandomNumberGenerator) -> void:
    var candidates: Array[Vector2i] = []
    for y: int in range(size.y):
        for x: int in range(size.x):
            var cell := Vector2i(x, y)
            if open_cells.has(cell):
                continue
            var neighbours := 0
            for direction: Vector2i in CARDINAL_DIRECTIONS:
                if open_cells.has(cell + direction):
                    neighbours += 1
            if neighbours >= 2:
                candidates.append(cell)

    _shuffle_with_rng(candidates, rng)
    var loops_to_add := mini(minimum_loops + rng.randi_range(0, 3), candidates.size())
    for index: int in range(loops_to_add):
        open_cells[candidates[index]] = true

func _shuffle_with_rng(values: Array[Vector2i], rng: RandomNumberGenerator) -> void:
    for index: int in range(values.size() - 1, 0, -1):
        var swap_index: int = rng.randi_range(0, index)
        var temporary: Vector2i = values[index]
        values[index] = values[swap_index]
        values[swap_index] = temporary

func _has_path(start: Vector2i, target: Vector2i, blocked: Dictionary) -> bool:
    var frontier: Array[Vector2i] = [start]
    var visited: Dictionary = {}
    visited[start] = true
    while not frontier.is_empty():
        var current: Vector2i = frontier.pop_front()
        if current == target:
            return true
        for direction: Vector2i in CARDINAL_DIRECTIONS:
            var next_cell: Vector2i = current + direction
            if _inside(next_cell) and not blocked.has(next_cell) and not visited.has(next_cell):
                visited[next_cell] = true
                frontier.append(next_cell)
    return false

func _inside(cell: Vector2i) -> bool:
    return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y
