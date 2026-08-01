class_name WaveData
extends Resource

@export_range(1, 100, 1) var wave_number := 1
@export var adventurer: AdventurerData
@export_range(0.1, 120.0, 0.1) var preparation_duration := 15.0
@export_range(0, 1000, 1) var bonus_reward := 0

func get_total_reward() -> int:
    if adventurer == null:
        return bonus_reward
    return adventurer.reward + bonus_reward

func is_valid() -> bool:
    return wave_number > 0 and adventurer != null and adventurer.is_valid() and preparation_duration > 0.0 and bonus_reward >= 0
