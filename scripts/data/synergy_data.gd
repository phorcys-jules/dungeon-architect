class_name SynergyData
extends Resource

@export var synergy_id := ""
@export var display_name := ""
@export var required_tags: Array[StringName] = []
@export var granted_tags: Array[StringName] = []
@export var modifiers: Dictionary = {}

func is_valid() -> bool:
    return not synergy_id.is_empty() and not display_name.is_empty() and required_tags.size() >= 2
