class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)
signal damaged(amount: int, current_health: int)
signal healed(amount: int, current_health: int)
signal died

@export_range(1, 100000, 1) var max_health: int = 100

var current_health: int = 100
var is_dead: bool = false

func _ready() -> void:
    reset()

func setup(new_max_health: int, start_full: bool = true) -> void:
    max_health = maxi(new_max_health, 1)
    current_health = max_health if start_full else mini(current_health, max_health)
    is_dead = current_health <= 0
    health_changed.emit(current_health, max_health)

func take_damage(amount: int) -> int:
    if amount <= 0 or is_dead:
        return 0

    var previous_health := current_health
    current_health = maxi(current_health - amount, 0)
    var applied_damage := previous_health - current_health

    damaged.emit(applied_damage, current_health)
    health_changed.emit(current_health, max_health)

    if current_health == 0:
        is_dead = true
        died.emit()

    return applied_damage

func heal(amount: int) -> int:
    if amount <= 0 or is_dead:
        return 0

    var previous_health := current_health
    current_health = mini(current_health + amount, max_health)
    var applied_healing := current_health - previous_health

    if applied_healing > 0:
        healed.emit(applied_healing, current_health)
        health_changed.emit(current_health, max_health)

    return applied_healing

func reset() -> void:
    current_health = max_health
    is_dead = false
    health_changed.emit(current_health, max_health)

func get_health_ratio() -> float:
    return float(current_health) / float(max_health)
