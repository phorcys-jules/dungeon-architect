extends SceneTree

const LabyrinthGeneratorScript := preload("res://scripts/core/labyrinth_generator.gd")
const REQUIRED_CELLS: Array[Vector2i] = [
    Vector2i(2, 2),
    Vector2i(12, 8),
    Vector2i(10, 2),
    Vector2i(3, 8),
    Vector2i(7, 8),
]

func _fail(message: String) -> void:
    push_error("LabyrinthGenerator test failed: %s" % message)
    quit(1)

func _open_lookup(layout: Dictionary) -> Dictionary:
    var result: Dictionary = {}
    for cell: Vector2i in layout.get("open_cells", []):
        result[cell] = true
    return result

func _junction_count(open_cells: Dictionary) -> int:
    var count := 0
    for candidate: Variant in open_cells:
        var cell: Vector2i = candidate
        var exits := 0
        for direction: Vector2i in LabyrinthGenerator.CARDINAL_DIRECTIONS:
            if open_cells.has(cell + direction):
                exits += 1
        if exits >= 3:
            count += 1
    return count

func _shortest_distance(open_cells: Dictionary, start: Vector2i, target: Vector2i) -> int:
    var frontier: Array[Vector2i] = [start]
    var distances := {start: 0}
    while not frontier.is_empty():
        var current: Vector2i = frontier.pop_front()
        if current == target:
            return int(distances[current])
        for direction: Vector2i in LabyrinthGenerator.CARDINAL_DIRECTIONS:
            var next_cell := current + direction
            if open_cells.has(next_cell) and not distances.has(next_cell):
                distances[next_cell] = int(distances[current]) + 1
                frontier.append(next_cell)
    return -1

func _init() -> void:
    var generator: LabyrinthGenerator = LabyrinthGeneratorScript.new()
    var first := generator.generate(20260802, REQUIRED_CELLS)
    var repeated := generator.generate(20260802, REQUIRED_CELLS)
    var different := generator.generate(20260803, REQUIRED_CELLS)

    if not generator.is_valid(first, REQUIRED_CELLS):
        _fail("generated layout is not traversable")
        return
    if generator.fingerprint(first) != generator.fingerprint(repeated):
        _fail("same seed produced a different layout")
        return
    if generator.fingerprint(first) == generator.fingerprint(different):
        _fail("different seeds produced the same layout")
        return

    var walls: Array[Vector2i] = []
    walls.assign(first.get("walls", []))
    if walls.is_empty():
        _fail("layout contains no walls")
        return
    if walls.has(generator.entrance) or walls.has(generator.treasure):
        _fail("entrance or treasure is blocked")
        return
    for required in REQUIRED_CELLS:
        if walls.has(required):
            _fail("required objective is blocked")
            return

    var open_cells := _open_lookup(first)
    var open_ratio := float(open_cells.size()) / float(generator.size.x * generator.size.y)
    if open_ratio < 0.55 or open_ratio > 0.82:
        _fail("corridor density is outside Pac-Man-like bounds: %.2f" % open_ratio)
        return
    if _junction_count(open_cells) < 12:
        _fail("layout does not contain enough junctions")
        return
    var direct_distance := absi(generator.treasure.x - generator.entrance.x) + absi(generator.treasure.y - generator.entrance.y)
    if _shortest_distance(open_cells, generator.entrance, generator.treasure) <= direct_distance:
        _fail("entrance still has a straight route to the treasure")
        return

    for seed_value in range(100, 200):
        var layout := generator.generate(seed_value, REQUIRED_CELLS)
        if not generator.is_valid(layout, REQUIRED_CELLS):
            _fail("invalid layout for seed %d" % seed_value)
            return
        if _junction_count(_open_lookup(layout)) < 10:
            _fail("not enough junctions for seed %d" % seed_value)
            return

    print("LabyrinthGenerator deterministic validation test passed")
    quit(0)
