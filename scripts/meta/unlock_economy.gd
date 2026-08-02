class_name UnlockEconomy
extends RefCounted

var resources := {"gold": 0, "essence": 0, "stone": 0, "bones": 0}
var unlocked: Dictionary = {}

func add_resource(resource_id: String, amount: int) -> void:
    resources[resource_id] = maxi(int(resources.get(resource_id, 0)) + amount, 0)

func can_afford(cost: Dictionary) -> bool:
    for key in cost:
        if int(resources.get(key, 0)) < int(cost[key]):
            return false
    return true

func purchase(unlock_id: String, cost: Dictionary) -> bool:
    if unlocked.has(unlock_id) or not can_afford(cost):
        return false
    for key in cost:
        resources[key] = int(resources.get(key, 0)) - int(cost[key])
    unlocked[unlock_id] = true
    return true

func is_unlocked(unlock_id: String) -> bool:
    return bool(unlocked.get(unlock_id, false))

func serialize() -> Dictionary:
    return {"resources": resources.duplicate(true), "unlocked": unlocked.duplicate(true)}

func restore(data: Dictionary) -> void:
    resources = data.get("resources", resources).duplicate(true)
    unlocked = data.get("unlocked", {}).duplicate(true)
