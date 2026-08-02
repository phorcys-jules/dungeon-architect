class_name MobileMonster
extends RefCounted

var cell := Vector2i.ZERO
var world_position := Vector2.ZERO
var path: Array[Vector2i] = []
var path_index := 0
var move_speed := 120.0
var home_cell := Vector2i.ZERO

func setup(start_cell: Vector2i, speed: float = 120.0) -> void:
    cell = start_cell
    home_cell = start_cell
    world_position = Vector2(start_cell)
    move_speed = maxf(speed, 1.0)
    path.clear()
    path_index = 0

func set_path(cells: Array[Vector2i]) -> void:
    path = cells.duplicate()
    path_index = 0
    if not path.is_empty() and path[0] == cell:
        path.remove_at(0)

func has_path() -> bool:
    return path_index < path.size()

func get_target_cell() -> Vector2i:
    if not has_path():
        return cell
    return path[path_index]

func tick_grid(delta: float, cell_size: float) -> bool:
    if not has_path():
        return false

    var target_cell := path[path_index]
    var target_world := Vector2(target_cell) * cell_size
    world_position = world_position.move_toward(target_world, move_speed * delta)

    if world_position.distance_to(target_world) <= 0.5:
        world_position = target_world
        cell = target_cell
        path_index += 1
        return true
    return false

func reset_to_home(cell_size: float) -> void:
    cell = home_cell
    world_position = Vector2(home_cell) * cell_size
    path.clear()
    path_index = 0
