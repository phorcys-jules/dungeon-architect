class_name CombatStats
extends Resource

@export var max_health := 100.0
@export var attack := 10.0
@export var armor := 0.0
@export var move_speed := 100.0
@export var attack_range := 32.0
@export_range(0.0, 1.0, 0.01) var critical_chance := 0.05
@export var critical_multiplier := 1.5

func duplicate_runtime() -> CombatStats:
    var copy := CombatStats.new()
    copy.max_health = max_health
    copy.attack = attack
    copy.armor = armor
    copy.move_speed = move_speed
    copy.attack_range = attack_range
    copy.critical_chance = critical_chance
    copy.critical_multiplier = critical_multiplier
    return copy
