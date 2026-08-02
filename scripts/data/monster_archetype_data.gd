class_name MonsterArchetypeData
extends Resource

@export var archetype_id := ""
@export var display_name := ""
@export var base_speed := 100.0
@export var base_damage := 10
@export var tags: Array[StringName] = []
@export var abilities: Array[StringName] = []
@export var effect_values: Dictionary = {}

func is_valid() -> bool:
    return not archetype_id.is_empty() and not display_name.is_empty() and base_speed > 0.0 and base_damage >= 0 and not tags.is_empty()

func has_ability(ability: StringName) -> bool:
    return abilities.has(ability)

func get_effect(key: StringName, default_value: float = 0.0) -> float:
    return float(effect_values.get(key, default_value))
