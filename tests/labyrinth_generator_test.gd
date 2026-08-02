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

    for seed_value in range(100, 200):
        var layout := generator.generate(seed_value, REQUIRED_CELLS)
        if not generator.is_valid(layout, REQUIRED_CELLS):
            _fail("invalid layout for seed %d" % seed_value)
            return

    print("LabyrinthGenerator deterministic validation test passed")
    quit(0)
