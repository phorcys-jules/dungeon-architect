class_name DenProgression
extends RefCounted

const MAX_LEVEL := 5

var level := 0
var stored_resources := 0

func get_capacity() -> int:
    return 2 + level * 2

func get_upgrade_cost() -> int:
    if level >= MAX_LEVEL:
        return 0
    return 40 + level * 35

func can_upgrade() -> bool:
    return level < MAX_LEVEL and stored_resources >= get_upgrade_cost()

func add_resources(amount: int) -> void:
    stored_resources += maxi(amount, 0)

func upgrade() -> bool:
    if not can_upgrade():
        return false
    stored_resources -= get_upgrade_cost()
    level += 1
    return true

func serialize() -> Dictionary:
    return {"level": level, "stored_resources": stored_resources}

func restore(data: Dictionary) -> void:
    level = clampi(int(data.get("level", 0)), 0, MAX_LEVEL)
    stored_resources = maxi(int(data.get("stored_resources", 0)), 0)
