class_name RunLootLedger
extends RefCounted

var carried_loot := 0
var captured_loot := 0
var recovered_ectoplasm := 0
var monster_recovery_cost := 0
var world_drops: Array[Dictionary] = []

func reset() -> void:
    carried_loot = 0
    captured_loot = 0
    recovered_ectoplasm = 0
    monster_recovery_cost = 0
    world_drops.clear()

func collect_relic(value: int = 3) -> void:
    carried_loot += maxi(value, 0)

func record_monster_neutralized(cell: Vector2i, value: int = 1, recovery_cost: int = 2) -> void:
    var amount := maxi(value, 0)
    recovered_ectoplasm += amount
    monster_recovery_cost += maxi(recovery_cost, amount)
    world_drops.append({"kind": "ectoplasm", "cell": cell, "amount": amount})

func capture_adventurer(cell: Vector2i) -> int:
    var dropped := carried_loot
    captured_loot += dropped
    carried_loot = 0
    if dropped > 0:
        world_drops.append({"kind": "stolen_loot", "cell": cell, "amount": dropped})
    return dropped

func lose_carried_loot() -> int:
    var lost := carried_loot
    carried_loot = 0
    return lost

func ectoplasm_net() -> int:
    return recovered_ectoplasm - monster_recovery_cost

func snapshot() -> Dictionary:
    return {
        "carried_loot": carried_loot,
        "captured_loot": captured_loot,
        "ectoplasm": recovered_ectoplasm,
        "monster_recovery_cost": monster_recovery_cost,
        "ectoplasm_net": ectoplasm_net(),
    }

func summary() -> String:
    return "Butin récupéré : %d\nEctoplasme : %d (coût de retour : %d)" % [captured_loot, recovered_ectoplasm, monster_recovery_cost]
