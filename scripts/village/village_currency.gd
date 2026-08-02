class_name VillageCurrency
extends RefCounted

const ID := "soul_shards"
const DISPLAY_NAME := "Éclats d'âme"
const SYMBOL := "◆"

var balance := 0

func can_afford(cost: int) -> bool:
    return cost >= 0 and balance >= cost

func deposit(amount: int) -> int:
    var credited := maxi(amount, 0)
    balance += credited
    return credited

func spend(cost: int) -> bool:
    if not can_afford(cost):
        return false
    balance -= cost
    return true

func formatted(amount: int = -1) -> String:
    var value := balance if amount < 0 else amount
    return "%s %d" % [SYMBOL, value]

func serialize() -> Dictionary:
    return {ID: balance}

func restore(data: Dictionary) -> void:
    balance = maxi(int(data.get(ID, 0)), 0)
