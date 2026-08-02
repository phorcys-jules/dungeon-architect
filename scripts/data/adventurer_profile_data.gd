class_name AdventurerProfileData
extends Resource

@export var profile_id: StringName
@export var display_name := ""
@export var speed_multiplier := 1.0
@export var health_multiplier := 1.0
@export var behaviour: StringName
@export var tags: Array[StringName] = []
@export var parameters: Dictionary = {}

func is_valid() -> bool:
    return not profile_id.is_empty() and not display_name.is_empty() and not behaviour.is_empty() and speed_multiplier > 0.0 and health_multiplier > 0.0
