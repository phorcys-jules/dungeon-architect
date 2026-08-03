class_name SquadFormationRuntime
extends RefCounted

const FORMATIONS := [&"escort", &"pack", &"ambush", &"treasure_guard"]
const ORDERS := [&"hold", &"converge", &"retreat"]

var formations: Dictionary = {}
var temporary_orders: Dictionary = {}

func configure(id: String, type: StringName, leader: String, members: Array[String]) -> Dictionary:
    if id.is_empty() or not FORMATIONS.has(type) or leader.is_empty() or not members.has(leader):
        return {"ok": false, "reason": "invalid_formation"}
    formations[id] = {"id": id, "type": type, "leader": leader, "members": members.duplicate()}
    return {"ok": true, "formation": formations[id].duplicate(true)}

func issue_order(id: String, order: StringName, target: Vector2i, duration: float) -> bool:
    if not formations.has(id) or not ORDERS.has(order) or duration <= 0.0:
        return false
    temporary_orders[id] = {"order": order, "target": target, "remaining": duration}
    return true

func tick(delta: float) -> void:
    for id in temporary_orders.keys():
        var order: Dictionary = temporary_orders[id]
        order.remaining = float(order.remaining) - delta
        if float(order.remaining) <= 0.0:
            temporary_orders.erase(id)
        else:
            temporary_orders[id] = order

func target_for(member: String, leader_cell: Vector2i, treasure: Vector2i, panic_target: Vector2i = Vector2i(-1, -1)) -> Dictionary:
    if panic_target != Vector2i(-1, -1):
        return {"target": panic_target, "source": "panic"}
    var formation := _formation_for(member)
    if formation.is_empty():
        return {"target": leader_cell, "source": "unassigned"}
    var id := String(formation.id)
    if temporary_orders.has(id):
        var active: Dictionary = temporary_orders[id]
        return {"target": active.target, "source": active.order}
    match StringName(formation.type):
        &"treasure_guard":
            return {"target": treasure, "source": "treasure_guard"}
        &"ambush":
            return {"target": leader_cell + Vector2i(1, 0), "source": "ambush"}
        &"pack":
            return {"target": leader_cell, "source": "pack"}
        _:
            return {"target": leader_cell + Vector2i(-1, 0), "source": "escort"}

func _formation_for(member: String) -> Dictionary:
    for formation in formations.values():
        if Array(formation.members).has(member):
            return formation
    return {}

func to_dict() -> Dictionary:
    return {"formations": formations.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    formations = Dictionary(data.get("formations", {})).duplicate(true)
