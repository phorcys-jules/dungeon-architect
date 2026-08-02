class_name RunBuildState
extends RefCounted

var selected_choice_ids: Array[StringName] = []
var source_tags: Array[StringName] = [&"ghost", &"slime", &"mimic"]
var modifiers: Dictionary = {}
var active_synergy_ids: Array[StringName] = []
var synergy_engine := SynergyEngine.new()

func configure_synergies(definitions: Array[SynergyData]) -> void:
    synergy_engine.configure(definitions)
    _refresh_synergies()

func apply_choice(choice: Dictionary) -> bool:
    var choice_id := StringName(choice.get("id", ""))
    if choice_id == &"" or selected_choice_ids.has(choice_id):
        return false
    selected_choice_ids.append(choice_id)
    var choice_modifiers: Dictionary = choice.get("modifiers", {})
    for key: Variant in choice_modifiers.keys():
        modifiers[key] = float(modifiers.get(key, 0.0)) + float(choice_modifiers[key])
    var tags: Array = choice.get("tags", [])
    for tag: Variant in tags:
        var tag_name := StringName(tag)
        if not source_tags.has(tag_name):
            source_tags.append(tag_name)
    _refresh_synergies()
    return true

func get_multiplier(key: StringName) -> float:
    return maxf(0.1, 1.0 + float(modifiers.get(key, 0.0)) + synergy_engine.get_modifier(key, 0.0))

func get_active_synergy_labels() -> Array[String]:
    var labels: Array[String] = []
    for definition: SynergyData in synergy_engine.definitions:
        if active_synergy_ids.has(StringName(definition.synergy_id)):
            labels.append("%s — %s" % [definition.display_name, _format_modifiers(definition.modifiers)])
    return labels

func _refresh_synergies() -> void:
    active_synergy_ids = synergy_engine.evaluate(source_tags)

func _format_modifiers(values: Dictionary) -> String:
    var parts: PackedStringArray = []
    for key: Variant in values.keys():
        parts.append("%s %.2fx" % [String(key).replace("_", " "), 1.0 + float(values[key])])
    return ", ".join(parts)
