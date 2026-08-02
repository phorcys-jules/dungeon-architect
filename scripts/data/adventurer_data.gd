class_name AdventurerData
extends Resource

@export var id := "adventurer"
@export var display_name := "Aventurier"
@export_multiline var description := ""
@export_range(1, 10000, 1) var max_health := 100
@export_range(0.1, 5.0, 0.01) var speed_multiplier := 1.0
@export_range(0, 1000, 1) var reward := 30
@export_range(0, 100, 1) var flat_armor := 0
@export_range(0.1, 2.0, 0.01) var trap_damage_multiplier := 1.0
@export_range(0.1, 2.0, 0.01) var defender_damage_multiplier := 1.0
@export var color := Color("62a7ff")

func is_valid() -> bool:
    return (
        not id.strip_edges().is_empty()
        and not display_name.strip_edges().is_empty()
        and max_health > 0
        and speed_multiplier > 0.0
        and reward >= 0
        and flat_armor >= 0
        and trap_damage_multiplier > 0.0
        and defender_damage_multiplier > 0.0
    )
