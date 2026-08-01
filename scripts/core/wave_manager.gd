class_name WaveManager
extends RefCounted

const MAX_WAVES := 5
const WAVE_RESOURCES := [
    preload("res://resources/waves/wave_01.tres"),
    preload("res://resources/waves/wave_02.tres"),
    preload("res://resources/waves/wave_03.tres"),
    preload("res://resources/waves/wave_04.tres"),
    preload("res://resources/waves/wave_05.tres"),
]

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

func get_current_wave_data() -> WaveData:
    var index := clampi(current_wave - 1, 0, WAVE_RESOURCES.size() - 1)
    return WAVE_RESOURCES[index] as WaveData

func get_adventurer_data() -> AdventurerData:
    return get_current_wave_data().adventurer

func get_adventurer_health() -> int:
    return get_adventurer_data().max_health

func get_speed_multiplier() -> float:
    return get_adventurer_data().speed_multiplier

func get_wave_reward() -> int:
    return get_current_wave_data().get_total_reward()

func get_preparation_duration() -> float:
    return get_current_wave_data().preparation_duration

func get_adventurer_name() -> String:
    return get_adventurer_data().display_name

func get_adventurer_description() -> String:
    return get_adventurer_data().description

func get_adventurer_color() -> Color:
    return get_adventurer_data().color

func get_profile_summary() -> String:
    return "%s — %d PV — vitesse %.2fx — récompense %d or" % [
        get_adventurer_name(),
        get_adventurer_health(),
        get_speed_multiplier(),
        get_wave_reward(),
    ]

func get_briefing() -> String:
    var description := get_adventurer_description().strip_edges()
    if description.is_empty():
        return get_profile_summary()
    return "%s\n%s" % [get_profile_summary(), description]

func get_label() -> String:
    return "Vague %d / %d — %s" % [current_wave, MAX_WAVES, get_adventurer_name()]

func is_configuration_valid() -> bool:
    if WAVE_RESOURCES.size() != MAX_WAVES:
        return false
    for index in range(WAVE_RESOURCES.size()):
        var wave := WAVE_RESOURCES[index] as WaveData
        if wave == null or not wave.is_valid() or wave.wave_number != index + 1:
            return false
    return true
