class_name SynergyEngine
extends RefCounted

var definitions: Array[SynergyData] = []
var active_ids: Array[StringName] = []
var combined_modifiers: Dictionary = {}

func configure(values: Array[SynergyData]) -> void:
    definitions.clear()
    for definition: SynergyData in values:
        if definition != null and definition.is_valid():
            definitions.append(definition)

func evaluate(source_tags: Array[StringName]) -> Array[StringName]:
    active_ids.clear()
    combined_modifiers.clear()
    var available: Dictionary = {}
    for tag: StringName in source_tags:
        available[tag] = true

    var changed := true
    while changed:
        changed = false
        for definition: SynergyData in definitions:
            var synergy_id := StringName(definition.synergy_id)
            if active_ids.has(synergy_id) or not _has_all_tags(definition.required_tags, available):
                continue
            active_ids.append(synergy_id)
            for granted_tag: StringName in definition.granted_tags:
                if not available.has(granted_tag):
                    available[granted_tag] = true
                    changed = true
            for key: Variant in definition.modifiers.keys():
                combined_modifiers[key] = float(combined_modifiers.get(key, 0.0)) + float(definition.modifiers[key])
    return active_ids.duplicate()

func get_modifier(key: StringName, default_value: float = 0.0) -> float:
    return float(combined_modifiers.get(key, default_value))

func _has_all_tags(required: Array[StringName], available: Dictionary) -> bool:
    for tag: StringName in required:
        if not available.has(tag):
            return false
    return true
