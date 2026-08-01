class_name SpikeTrap
extends Node

signal triggered(damage: int)
signal cooldown_changed(time_left: float)

@export var damage := 35
@export var cooldown_duration := 1.5

var cell := Vector2i.ZERO
var cooldown_left := 0.0

var is_ready: bool:
    get:
        return cooldown_left <= 0.0

func setup(target_cell: Vector2i) -> void:
    cell = target_cell
    cooldown_left = 0.0

func tick(delta: float) -> void:
    if cooldown_left <= 0.0:
        return
    cooldown_left = maxf(cooldown_left - delta, 0.0)
    cooldown_changed.emit(cooldown_left)

func try_trigger(target_health: HealthComponent) -> bool:
    if not is_ready or target_health == null or target_health.is_dead:
        return false
    target_health.take_damage(damage)
    cooldown_left = cooldown_duration
    triggered.emit(damage)
    cooldown_changed.emit(cooldown_left)
    return true

func reset() -> void:
    cooldown_left = 0.0
    cooldown_changed.emit(cooldown_left)
