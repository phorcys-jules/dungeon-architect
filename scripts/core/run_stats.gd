class_name RunStats
extends RefCounted

var elapsed_time := 0.0
var total_damage := 0
var traps_triggered := 0
var defender_attacks := 0
var result := ""

func reset() -> void:
    elapsed_time = 0.0
    total_damage = 0
    traps_triggered = 0
    defender_attacks = 0
    result = ""

func tick(delta: float) -> void:
    elapsed_time += maxf(delta, 0.0)

func record_trap(damage: int) -> void:
    traps_triggered += 1
    total_damage += maxi(damage, 0)

func record_defender_attack(damage: int) -> void:
    defender_attacks += 1
    total_damage += maxi(damage, 0)

func finish(new_result: String) -> void:
    if result.is_empty():
        result = new_result

func is_finished() -> bool:
    return not result.is_empty()

func summary() -> String:
    return "Temps : %.1f s\nDégâts infligés : %d\nPièges déclenchés : %d\nAttaques des défenseurs : %d" % [elapsed_time, total_damage, traps_triggered, defender_attacks]
