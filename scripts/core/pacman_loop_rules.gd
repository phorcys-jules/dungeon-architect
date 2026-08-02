class_name PacmanLoopRules
extends RefCounted

enum Behaviour { CHASER, AMBUSHER, GUARDIAN, HERDER }

var panic_time_left := 0.0
var door_cooldown_left := 0.0
var panic_duration := 6.0
var door_cooldown := 2.0

func tick(delta: float) -> void:
    panic_time_left = maxf(panic_time_left - delta, 0.0)
    door_cooldown_left = maxf(door_cooldown_left - delta, 0.0)

func activate_panic() -> void:
    panic_time_left = panic_duration

func is_panicking() -> bool:
    return panic_time_left > 0.0

func get_power_ratio() -> float:
    if panic_duration <= 0.0:
        return 0.0
    return clampf(panic_time_left / panic_duration, 0.0, 1.0)

func get_flee_target(monster: Vector2i, adventurer: Vector2i, grid_size: Vector2i, blocked_cells: Array[Vector2i], reserved: Array[Vector2i] = []) -> Vector2i:
    var best_target := monster
    var best_distance := -1.0
    for y in grid_size.y:
        for x in grid_size.x:
            var candidate := Vector2i(x, y)
            if blocked_cells.has(candidate) or reserved.has(candidate):
                continue
            var distance := candidate.distance_squared_to(adventurer)
            if distance > best_distance:
                best_distance = distance
                best_target = candidate
    return best_target

func can_toggle_door() -> bool:
    return door_cooldown_left <= 0.0

func consume_door_toggle() -> bool:
    if not can_toggle_door():
        return false
    door_cooldown_left = door_cooldown
    return true

func get_target(behaviour: Behaviour, adventurer: Vector2i, direction: Vector2i, treasure: Vector2i, exit_hint: Vector2i) -> Vector2i:
    match behaviour:
        Behaviour.CHASER:
            return adventurer
        Behaviour.AMBUSHER:
            return adventurer + direction * 3
        Behaviour.GUARDIAN:
            return treasure
        Behaviour.HERDER:
            return exit_hint
    return adventurer

func is_captured(adventurer: Vector2i, monster_cells: Array[Vector2i], blocked_cells: Array[Vector2i]) -> bool:
    var neighbours: Array[Vector2i] = [
        adventurer + Vector2i.LEFT,
        adventurer + Vector2i.RIGHT,
        adventurer + Vector2i.UP,
        adventurer + Vector2i.DOWN,
    ]
    for neighbour in neighbours:
        if not blocked_cells.has(neighbour) and not monster_cells.has(neighbour):
            return false
    return true
