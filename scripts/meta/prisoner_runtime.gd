class_name PrisonerRuntime
extends RefCounted

var prisoners: Dictionary = {}
var capacity := 2

func set_capacity(value: int) -> void:
    capacity = clampi(value, 1, 8)

func capture(id: String, name: String, faction: StringName, rank: int, seed_value: int) -> Dictionary:
    if id.is_empty() or prisoners.has(id):
        return {"ok": false, "reason": "duplicate"}
    if prisoners.size() >= capacity:
        return {"ok": false, "reason": "cells_full"}
    prisoners[id] = {"id": id, "name": name, "faction": faction, "rank": clampi(rank, 1, 5), "seed": seed_value, "days": 0, "decision": "", "resolved": false, "escape_risk": 0.08 + float(rank) * 0.04}
    return {"ok": true, "prisoner": prisoners[id].duplicate(true)}

func decide(id: String, decision: StringName, laboratory_level := 0) -> Dictionary:
    if not prisoners.has(id) or bool(prisoners[id].resolved):
        return {"ok": false, "reason": "unavailable"}
    var prisoner: Dictionary = prisoners[id]
    prisoner.decision = decision
    prisoner.resolved = true
    prisoners[id] = prisoner
    match decision:
        &"interrogate":
            return {"ok": true, "intel": _intel(prisoner, laboratory_level), "cost": {"essence": 5}}
        &"ransom":
            return {"ok": true, "reward": {"gold": 20 + int(prisoner.rank) * 15}, "faction_hostility": 1}
        &"release":
            return {"ok": true, "reward": {"reputation": 1}, "faction_hostility": -1}
        _:
            prisoner.resolved = false
            prisoners[id] = prisoner
            return {"ok": false, "reason": "unknown_decision"}

func _intel(prisoner: Dictionary, laboratory_level: int) -> Dictionary:
    var facts := ["faction:%s" % String(prisoner.faction), "resistance:%s" % (["fire", "fear", "frost"][abs(int(prisoner.seed)) % 3]), "route:%d" % (abs(int(prisoner.seed)) % 3), "boss_phase:%d" % (1 + abs(int(prisoner.seed)) % 3)]
    return {"facts": facts.slice(0, clampi(1 + laboratory_level, 1, facts.size())), "source": prisoner.id}

func tick_day(campaign_seed: int) -> Array[Dictionary]:
    var events: Array[Dictionary] = []
    for id in prisoners.keys():
        var prisoner: Dictionary = prisoners[id]
        if bool(prisoner.resolved):
            continue
        prisoner.days = int(prisoner.days) + 1
        var roll := float(abs(hash([campaign_seed, int(prisoner.seed), int(prisoner.days)])) % 10000) / 10000.0
        if roll < float(prisoner.escape_risk):
            events.append({"type": "escape", "id": id, "faction": prisoner.faction})
            prisoners.erase(id)
        else:
            prisoners[id] = prisoner
    return events

func rescue_targets(faction: StringName) -> Array[String]:
    var result: Array[String] = []
    for id in prisoners:
        if not bool(prisoners[id].resolved) and StringName(prisoners[id].faction) == faction:
            result.append(String(id))
    result.sort()
    return result

func to_dict() -> Dictionary:
    return {"capacity": capacity, "prisoners": prisoners.duplicate(true)}

func from_dict(data: Dictionary) -> void:
    capacity = clampi(int(data.get("capacity", 2)), 1, 8)
    prisoners = Dictionary(data.get("prisoners", {})).duplicate(true)
