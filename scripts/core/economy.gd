class_name Economy
extends RefCounted

signal gold_changed(current_gold: int)

var starting_gold := 100
var current_gold := 100

func reset() -> void:
    current_gold = maxi(starting_gold, 0)
    gold_changed.emit(current_gold)

func can_afford(cost: int) -> bool:
    return cost >= 0 and current_gold >= cost

func spend(cost: int) -> bool:
    if not can_afford(cost):
        return false
    current_gold -= cost
    gold_changed.emit(current_gold)
    return true

func add_gold(amount: int) -> void:
    if amount <= 0:
        return
    current_gold += amount
    gold_changed.emit(current_gold)
