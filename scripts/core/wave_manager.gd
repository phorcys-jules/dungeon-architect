class_name WaveManager
extends RefCounted

const BASE_HEALTH := 100
const HEALTH_PER_WAVE := 25
const BASE_SPEED_MULTIPLIER := 1.0
const SPEED_PER_WAVE := 0.08
const MAX_WAVES := 5

var current_wave := 1

func reset() -> void:
    current_wave = 1

func has_next_wave() -> bool:
    return current_wave < MAX_WAVES

func advance() -> bool:
    if not has_next_wave():
        return false
    current_wave += 1
    return true

func get_adventurer_health() -> int:
    return BASE_HEALTH + (current_wave - 1) * HEALTH_PER_WAVE

func get_speed_multiplier() -> float:
    return BASE_SPEED_MULTIPLIER + (current_wave - 1) * SPEED_PER_WAVE

func get_wave_reward() -> int:
    return 20 + current_wave * 10

func get_label() -> String:
    return "Vague %d / %d" % [current_wave, MAX_WAVES]
