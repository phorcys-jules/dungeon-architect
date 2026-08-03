class_name EnvironmentFlowRuntime
extends RefCounted

const TYPES := [&"water", &"fire", &"smoke", &"frost", &"corruption"]
const MAX_INTENSITY := 3
var cells: Dictionary = {}

func seed(cell: Vector2i, type: StringName, intensity := 1) -> bool:
    if not TYPES.has(type) or intensity <= 0:
        return false
    cells[cell] = {"type": type, "intensity": clampi(intensity, 1, MAX_INTENSITY)}
    return true

func step(size: Vector2i, blocked: Array[Vector2i], closed_doors: Array[Vector2i] = []) -> Dictionary:
    var next := cells.duplicate(true)
    var interactions: Array[Dictionary] = []
    var origins: Array = cells.keys()
    origins.sort_custom(func(a: Vector2i, b: Vector2i): return a.y < b.y or (a.y == b.y and a.x < b.x))
    for origin: Vector2i in origins:
        var source: Dictionary = cells[origin]
        for direction in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
            var target: Vector2i = origin + direction
            if target.x < 0 or target.y < 0 or target.x >= size.x or target.y >= size.y or blocked.has(target) or closed_doors.has(target):
                continue
            if next.has(target):
                var reaction := _react(source, next[target])
                if not reaction.is_empty():
                    next[target] = reaction.result
                    interactions.append({"cell": target, "name": reaction.name})
            elif int(source.intensity) > 1 or source.type == &"smoke":
                next[target] = {"type": source.type, "intensity": maxi(int(source.intensity) - 1, 1)}
    cells = next
    return {"cells": cells.duplicate(true), "interactions": interactions}

func _react(left: Dictionary, right: Dictionary) -> Dictionary:
    var pair := [String(left.type), String(right.type)]
    pair.sort()
    match "+".join(pair):
        "fire+water": return {"name": "steam", "result": {"type": &"smoke", "intensity": 2}}
        "fire+frost": return {"name": "thermal_shock", "result": {"type": &"water", "intensity": 1}}
        "corruption+water": return {"name": "tainted_pool", "result": {"type": &"corruption", "intensity": 2}}
        "fire+smoke": return {"name": "inferno", "result": {"type": &"fire", "intensity": 3}}
        "frost+water": return {"name": "frozen_floor", "result": {"type": &"frost", "intensity": 2}}
        _: return {}

func movement_cost(cell: Vector2i, actor_tags: Array[String]) -> float:
    if not cells.has(cell):
        return 0.0
    var type: StringName = cells[cell].type
    if actor_tags.has("resist:%s" % type):
        return 0.0
    return {&"water": 0.4, &"fire": 2.0, &"smoke": 0.8, &"frost": 1.2, &"corruption": 1.5}.get(type, 0.0)

func to_dict() -> Dictionary:
    var serialized := {}
    for cell in cells:
        serialized["%d,%d" % [cell.x, cell.y]] = cells[cell]
    return serialized

func from_dict(data: Dictionary) -> void:
    cells.clear()
    for key in data:
        var parts := String(key).split(",")
        if parts.size() == 2:
            cells[Vector2i(int(parts[0]), int(parts[1]))] = Dictionary(data[key]).duplicate(true)
