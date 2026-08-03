class_name DefenseEvolution
extends RefCounted

const MAX_LEVEL := 2
const REFUND_RATE := 0.5
const BRANCHES := {
    "power": {"name": "Puissance", "damage_multiplier": 1.25, "cooldown_multiplier": 1.0, "range_multiplier": 1.0},
    "tempo": {"name": "Cadence", "damage_multiplier": 1.0, "cooldown_multiplier": 0.82, "range_multiplier": 1.08},
}

var records: Dictionary = {}

func register(cell: Vector2i, kind: String, base_cost: int, base_stats: Dictionary) -> void:
    records[cell] = {"kind": kind, "base_cost": maxi(base_cost, 0), "spent": 0, "level": 0, "branch": "", "base_stats": base_stats.duplicate(true)}

func inspect(cell: Vector2i) -> Dictionary:
    return Dictionary(records.get(cell, {})).duplicate(true)

func upgrade(cell: Vector2i, branch: String, available_gold: int) -> Dictionary:
    if not records.has(cell) or not BRANCHES.has(branch):
        return {"ok": false, "reason": "unknown"}
    var record: Dictionary = records[cell]
    if int(record.level) >= MAX_LEVEL:
        return {"ok": false, "reason": "max_level"}
    if not String(record.branch).is_empty() and String(record.branch) != branch:
        return {"ok": false, "reason": "branch_locked"}
    var cost := 18 + int(record.level) * 12
    if available_gold < cost:
        return {"ok": false, "reason": "insufficient_gold", "cost": cost}
    record.branch = branch
    record.level = int(record.level) + 1
    record.spent = int(record.spent) + cost
    records[cell] = record
    return {"ok": true, "cost": cost, "stats": evolved_stats(cell), "record": record.duplicate(true)}

func evolved_stats(cell: Vector2i) -> Dictionary:
    var record := inspect(cell)
    if record.is_empty() or String(record.branch).is_empty():
        return Dictionary(record.get("base_stats", {})).duplicate(true)
    var definition: Dictionary = BRANCHES[record.branch]
    var level := int(record.level)
    var stats: Dictionary = record.base_stats.duplicate(true)
    stats.damage = roundi(float(stats.get("damage", 0)) * pow(float(definition.damage_multiplier), level))
    stats.cooldown = float(stats.get("cooldown", 1.0)) * pow(float(definition.cooldown_multiplier), level)
    stats.range = float(stats.get("range", 1.0)) * pow(float(definition.range_multiplier), level)
    return stats

func recycle(cell: Vector2i) -> Dictionary:
    if not records.has(cell):
        return {"ok": false, "refund": 0}
    var record: Dictionary = records[cell]
    var invested := int(record.base_cost) + int(record.spent)
    var refund := floori(float(invested) * REFUND_RATE)
    records.erase(cell)
    return {"ok": true, "refund": mini(refund, invested), "invested": invested}
