class_name VillageBuildingData
extends Resource

@export var building_id: StringName
@export var display_name := ""
@export var max_level := 3
@export var base_cost := 50
@export var bonus_key: StringName
@export var bonus_per_level := 0.1

func cost_for_level(level: int) -> int:
    return base_cost * maxi(level, 1)

func is_valid() -> bool:
    return not building_id.is_empty() and not display_name.is_empty() and max_level > 0 and base_cost >= 0 and not bonus_key.is_empty()
