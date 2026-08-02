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

    var open_cells := _carve_corridor_network(rng)
    _connect_required_cells(open_cells, required_cells, rng)
    _add_loops(open_cells, rng)
    _add_route_gates(open_cells, protected, rng)

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

func _carve_corridor_network(rng: RandomNumberGenerator) -> Dictionary:
    var open_cells: Dictionary = {}
    var spacing := 3 if wall_density >= 0.28 else 2
    var horizontal_lanes := _lane_positions(size.y, spacing, rng)
    var vertical_lanes := _lane_positions(size.x, spacing, rng)
    if not horizontal_lanes.has(entrance.y):
        horizontal_lanes.append(entrance.y)

    for y: int in horizontal_lanes:
        for x: int in range(size.x):
            open_cells[Vector2i(x, y)] = true
    for x: int in vertical_lanes:
        for y: int in range(size.y):
            open_cells[Vector2i(x, y)] = true

    return open_cells

func _lane_positions(length: int, spacing: int, rng: RandomNumberGenerator) -> Array[int]:
    var lanes: Array[int] = []
    var position := 1
    while position < length - 1:
        lanes.append(position)
        position += spacing
    if length > 3 and not lanes.has(length - 2):
        lanes.append(length - 2)
    if lanes.size() > 2:
        var index := rng.randi_range(1, lanes.size() - 2)
        lanes[index] = clampi(lanes[index] + rng.randi_range(-1, 1), 1, length - 2)
    return lanes

func _connect_required_cells(open_cells: Dictionary, required_cells: Array[Vector2i], rng: RandomNumberGenerator) -> void:
    var targets: Array[Vector2i] = required_cells.duplicate()
    targets.append(entrance)
    targets.append(treasure)
    for target: Vector2i in targets:
        if open_cells.has(target):
            continue
        var nearest := _nearest_open_cell(target, open_cells)
        var cursor := target
        open_cells[cursor] = true
        var horizontal_first := rng.randi_range(0, 1) == 0
        if horizontal_first:
            cursor = _carve_axis(cursor, nearest, true, open_cells)
            _carve_axis(cursor, nearest, false, open_cells)
        else:
            cursor = _carve_axis(cursor, nearest, false, open_cells)
            _carve_axis(cursor, nearest, true, open_cells)

func _nearest_open_cell(origin: Vector2i, open_cells: Dictionary) -> Vector2i:
    var nearest := entrance
    var best_distance := 1_000_000
    for candidate: Variant in open_cells:
        var cell: Vector2i = candidate
        var distance := absi(cell.x - origin.x) + absi(cell.y - origin.y)
        if distance < best_distance:
            nearest = cell
            best_distance = distance
    return nearest

func _carve_axis(cursor: Vector2i, target: Vector2i, horizontal: bool, open_cells: Dictionary) -> Vector2i:
    var destination := target.x if horizontal else target.y
    while (cursor.x if horizontal else cursor.y) != destination:
        if horizontal:
            cursor.x += 1 if destination > cursor.x else -1
        else:
            cursor.y += 1 if destination > cursor.y else -1
        open_cells[cursor] = true
    return cursor

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

func _add_route_gates(open_cells: Dictionary, protected: Dictionary, rng: RandomNumberGenerator) -> void:
    var candidates: Array[Vector2i] = []
    for x: int in range(2, size.x - 2):
        var cell := Vector2i(x, entrance.y)
        if protected.has(cell) or not open_cells.has(cell):
            continue
        if open_cells.has(cell + Vector2i.LEFT) and open_cells.has(cell + Vector2i.RIGHT):
            candidates.append(cell)
    _shuffle_with_rng(candidates, rng)
    var desired_gates := mini(3, candidates.size())
    var placed := 0
    for cell: Vector2i in candidates:
        if placed >= desired_gates:
            break
        open_cells.erase(cell)
        if _protected_cells_connected(open_cells, protected) and _all_open_cells_connected(open_cells):
            placed += 1
        else:
            open_cells[cell] = true

func _protected_cells_connected(open_cells: Dictionary, protected: Dictionary) -> bool:
    for target: Variant in protected:
        var target_cell: Vector2i = target
        if not _has_open_path(entrance, target_cell, open_cells):
            return false
    return true

func _has_open_path(start: Vector2i, target: Vector2i, open_cells: Dictionary) -> bool:
    if not open_cells.has(start) or not open_cells.has(target):
        return false
    var frontier: Array[Vector2i] = [start]
    var visited := {start: true}
    while not frontier.is_empty():
        var current: Vector2i = frontier.pop_front()
        if current == target:
            return true
        for direction: Vector2i in CARDINAL_DIRECTIONS:
            var next_cell := current + direction
            if open_cells.has(next_cell) and not visited.has(next_cell):
                visited[next_cell] = true
                frontier.append(next_cell)
    return false

func _all_open_cells_connected(open_cells: Dictionary) -> bool:
    if open_cells.is_empty():
        return false
    var first_cell: Vector2i = open_cells.keys()[0]
    var frontier: Array[Vector2i] = [first_cell]
    var visited := {first_cell: true}
    while not frontier.is_empty():
        var current: Vector2i = frontier.pop_front()
        for direction: Vector2i in CARDINAL_DIRECTIONS:
            var next_cell := current + direction
            if open_cells.has(next_cell) and not visited.has(next_cell):
                visited[next_cell] = true
                frontier.append(next_cell)
    return visited.size() == open_cells.size()

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
