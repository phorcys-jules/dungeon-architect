class_name CollectibleRoute
extends RefCounted

var remaining: Array[Vector2i] = []
var collected_count := 0

func setup(cells: Array[Vector2i]) -> void:
    remaining = cells.duplicate()
    collected_count = 0

func reset(cells: Array[Vector2i]) -> void:
    setup(cells)

func has_remaining() -> bool:
    return not remaining.is_empty()

func get_remaining_count() -> int:
    return remaining.size()

func can_enter_treasure() -> bool:
    return remaining.is_empty()

func collect_at(cell: Vector2i) -> bool:
    var index := remaining.find(cell)
    if index < 0:
        return false
    remaining.remove_at(index)
    collected_count += 1
    return true

func get_next_target(from_cell: Vector2i) -> Vector2i:
    if remaining.is_empty():
        return from_cell

    var best := remaining[0]
    var best_distance := _manhattan(from_cell, best)
    for cell in remaining:
        var distance := _manhattan(from_cell, cell)
        if distance < best_distance:
            best = cell
            best_distance = distance
    return best

func _manhattan(a: Vector2i, b: Vector2i) -> int:
    return absi(a.x - b.x) + absi(a.y - b.y)
