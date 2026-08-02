class_name SpikeTrap
extends Node

signal triggered(damage: int)
signal cooldown_changed(time_left: float)
signal status_applied(effect_id: StringName, duration: float, strength: float)

@export var damage := 35
@export var cooldown_duration := 1.5
var trap_id: StringName = &"spikes"
var display_name := "Pointes"
var effect_id: StringName = &""
var effect_duration := 0.0
var effect_strength := 1.0
var visual_color := Color("ed6a5a")

var cell := Vector2i.ZERO
var cooldown_left := 0.0

var is_ready: bool:
    get:
        return cooldown_left <= 0.0

func setup(target_cell: Vector2i) -> void:
    cell = target_cell
    cooldown_left = 0.0

func configure(definition: Dictionary) -> void:
    trap_id = StringName(definition.get("id", trap_id))
    display_name = String(definition.get("name", display_name))
    damage = int(definition.get("damage", damage))
    cooldown_duration = float(definition.get("cooldown", cooldown_duration))
    effect_id = StringName(definition.get("effect", &""))
    effect_duration = float(definition.get("duration", 0.0))
    effect_strength = float(definition.get("strength", 1.0))
    visual_color = Color(definition.get("color", visual_color))

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
    if not effect_id.is_empty() and effect_duration > 0.0:
        status_applied.emit(effect_id, effect_duration, effect_strength)
    cooldown_changed.emit(cooldown_left)
    return true

func reset() -> void:
    cooldown_left = 0.0
    cooldown_changed.emit(cooldown_left)
