class_name DenProgression
extends RefCounted

const MAX_LEVEL := 5

var level := 0
var currency := VillageCurrency.new()
var soul_shards: int:
    get: return currency.balance
    set(value): currency.balance = maxi(value, 0)
var stored_resources: int:
    get: return soul_shards
    set(value): soul_shards = value

func get_capacity() -> int:
    return 2 + level * 2

func get_upgrade_cost() -> int:
    if level >= MAX_LEVEL:
        return 0
    return 40 + level * 35

func can_upgrade() -> bool:
    return level < MAX_LEVEL and currency.can_afford(get_upgrade_cost())

func add_resources(amount: int) -> void:
    add_soul_shards(amount)

func add_soul_shards(amount: int) -> int:
    return currency.deposit(amount)

func upgrade() -> bool:
    if not can_upgrade():
        return false
    if not currency.spend(get_upgrade_cost()):
        return false
    level += 1
    return true

func serialize() -> Dictionary:
    return {"level": level, "currency": currency.serialize()}

func restore(data: Dictionary) -> void:
    level = clampi(int(data.get("level", 0)), 0, MAX_LEVEL)
    var saved_currency: Variant = data.get("currency", {})
    if typeof(saved_currency) == TYPE_DICTIONARY and not saved_currency.is_empty():
        currency.restore(saved_currency)
    else:
        soul_shards = int(data.get("stored_resources", 0))
