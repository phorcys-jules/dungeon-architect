class_name TacticalHeatmap
extends RefCounted

const LAYERS := [&"traffic", &"damage", &"captures", &"triggers", &"coverage"]
var current: Dictionary = {}
var previous: Dictionary = {}
var enabled: Dictionary = {&"traffic": true, &"damage": false, &"captures": false, &"triggers": false, &"coverage": false}

func record(layer: StringName, cell: Vector2i, amount: float = 1.0) -> void:
    if not LAYERS.has(layer):
        return
    if not current.has(layer):
        current[layer] = {}
    current[layer][cell] = float(current[layer].get(cell, 0.0)) + maxf(amount, 0.0)

func finish_wave() -> void:
    previous = current.duplicate(true)
    current.clear()

func toggle(layer: StringName) -> bool:
    if not LAYERS.has(layer):
        return false
    enabled[layer] = not bool(enabled.get(layer, false))
    return bool(enabled[layer])

func intensity(layer: StringName, cell: Vector2i, use_previous := true) -> float:
    var source: Dictionary = previous if use_previous else current
    var values: Dictionary = source.get(layer, {})
    if values.is_empty():
        return 0.0
    var maximum := 0.0
    for value in values.values():
        maximum = maxf(maximum, float(value))
    return 0.0 if maximum <= 0.0 else float(values.get(cell, 0.0)) / maximum

func snapshot() -> Dictionary:
    return previous.duplicate(true)
