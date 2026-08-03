class_name MobileMonster
extends RefCounted

var cell := Vector2i.ZERO
var world_position := Vector2.ZERO
var path: Array[Vector2i] = []
var path_index := 0
var move_speed := 120.0
var disguised := false
var home_cell := Vector2i.ZERO
var max_health := 60
var current_health := 60
var respawn_left := 0.0
var returning_home := false
var activation_delay_left := 0.0

func setup(start_cell: Vector2i, speed: float = 120.0, health: int = 60) -> void:
    cell = start_cell
    home_cell = start_cell
    world_position = Vector2(start_cell)
    move_speed = maxf(speed, 1.0)
    max_health = maxi(health, 1)
    current_health = max_health
    respawn_left = 0.0
    returning_home = false
    activation_delay_left = 0.0
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
    if disguised or not is_active() or not has_path():
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

func revive_at_home(cell_size: float) -> void:
    current_health = max_health
    respawn_left = 0.0
    returning_home = false
    reset_to_home(cell_size)

func hold_at_home(delay: float, cell_size: float) -> void:
    revive_at_home(cell_size)
    activation_delay_left = maxf(delay, 0.0)

func set_disguised(value: bool) -> void:
    disguised = value
    if disguised:
        path.clear()
        path_index = 0


func is_active() -> bool:
    return respawn_left <= 0.0 and activation_delay_left <= 0.0 and current_health > 0

func take_damage(amount: int, respawn_delay: float = 3.0) -> int:
    if not is_active() or amount <= 0:
        return 0
    var previous_health := current_health
    current_health = maxi(current_health - amount, 0)
    if current_health <= 0:
        respawn_left = maxf(respawn_delay, 0.1)
        returning_home = true
        path.clear()
        path_index = 0
    return previous_health - current_health

func tick_respawn(delta: float, cell_size: float) -> bool:
    if current_health > 0:
        activation_delay_left = maxf(activation_delay_left - delta, 0.0)
        return false
    respawn_left = maxf(respawn_left - delta, 0.0)
    if returning_home:
        var home_world := Vector2(home_cell) * cell_size
        world_position = world_position.move_toward(home_world, move_speed * 1.65 * delta)
        if world_position.distance_to(home_world) <= 0.5:
            world_position = home_world
            cell = home_cell
            returning_home = false
    if respawn_left > 0.0 or returning_home:
        return false
    current_health = max_health
    activation_delay_left = 0.0
    return true

func get_health_ratio() -> float:
    return float(current_health) / float(max_health)
