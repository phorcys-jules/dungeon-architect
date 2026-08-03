class_name PatrolZoneRuntime
extends RefCounted

const TYPES := [&"patrol", &"guard", &"ambush", &"retreat"]
var zones: Dictionary = {}
var assignments: Dictionary = {}
var temporary_orders: Dictionary = {}

func define(id: String, type: StringName, cells: Array[Vector2i], reachable: Array[Vector2i]) -> Dictionary:
    if id.is_empty() or not TYPES.has(type) or cells.is_empty():
        return {"ok": false, "reason": "invalid_zone"}
    for cell in cells:
        if not reachable.has(cell):
            return {"ok": false, "reason": "unreachable_cell", "cell": cell}
    zones[id] = {"id": id, "type": type, "cells": cells.duplicate(), "priority": _priority(type)}
    return {"ok": true, "zone": zones[id].duplicate(true)}

func assign(monster_id: String, zone_id: String) -> bool:
    if monster_id.is_empty() or not zones.has(zone_id):
        return false
    assignments[monster_id] = zone_id
    return true

func target_for(monster_id: String, monster_cell: Vector2i, emergency_target: Vector2i = Vector2i(-1, -1)) -> Dictionary:
    if temporary_orders.has(monster_id):
        return {"target": temporary_orders[monster_id], "source": "temporary_order"}
    if emergency_target != Vector2i(-1, -1):
        return {"target": emergency_target, "source": "emergency", "return_zone": assignments.get(monster_id, "")}
    var zone_id := String(assignments.get(monster_id, ""))
    if not zones.has(zone_id):
        return {"target": monster_cell, "source": "idle"}
    var zone: Dictionary = zones[zone_id]
    var cells: Array = zone.cells
    var target: Vector2i = cells[abs(monster_cell.x + monster_cell.y) % cells.size()]
    return {"target": target, "source": zone.type, "priority": zone.priority}

func order(monster_ids: Array[String], target: Vector2i) -> void:
    for monster_id in monster_ids:
        temporary_orders[monster_id] = target

func clear_orders() -> void:
    temporary_orders.clear()

func _priority(type: StringName) -> int:
    return {&"guard": 4, &"ambush": 3, &"patrol": 2, &"retreat": 1}.get(type, 0)

func to_dict() -> Dictionary:
    return {"zones": zones.duplicate(true), "assignments": assignments.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    zones = Dictionary(data.get("zones", {})).duplicate(true)
    assignments = Dictionary(data.get("assignments", {})).duplicate(true)
