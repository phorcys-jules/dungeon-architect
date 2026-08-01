class_name Defender
extends Node

signal attacked(damage: int)

@export var damage := 12
@export var attack_range_cells := 2.25
@export var cooldown := 1.0

var grid_cell := Vector2i.ZERO
var world_position := Vector2.ZERO
var cooldown_left := 0.0
var is_ready := true

func setup(cell: Vector2i, position: Vector2) -> void:
    grid_cell = cell
    world_position = position
    reset()

func tick(delta: float) -> void:
    if cooldown_left <= 0.0:
        is_ready = true
        return
    cooldown_left = maxf(cooldown_left - delta, 0.0)
    is_ready = cooldown_left <= 0.0

func try_attack(target_position: Vector2, target_health: HealthComponent, cell_size: float) -> bool:
    if not is_ready or target_health == null or target_health.is_dead:
        return false
    if world_position.distance_to(target_position) > attack_range_cells * cell_size:
        return false
    target_health.take_damage(damage)
    cooldown_left = cooldown
    is_ready = false
    attacked.emit(damage)
    return true

func reset() -> void:
    cooldown_left = 0.0
    is_ready = true
