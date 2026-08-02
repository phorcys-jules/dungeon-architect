class_name RunResultRecord
extends RefCounted

var run_id := ""
var duration_seconds := 0.0
var waves_completed := 0
var damage_dealt := 0
var traps_triggered := 0
var monsters_lost := 0
var treasure_protected := false
var victory := false
var difficulty_id := "normal"

func to_dict() -> Dictionary:
    return {
        "run_id": run_id,
        "duration_seconds": duration_seconds,
        "waves_completed": waves_completed,
        "damage_dealt": damage_dealt,
        "traps_triggered": traps_triggered,
        "monsters_lost": monsters_lost,
        "treasure_protected": treasure_protected,
        "victory": victory,
        "difficulty_id": difficulty_id,
    }

static func from_dict(data: Dictionary) -> RunResultRecord:
    var record := RunResultRecord.new()
    record.run_id = str(data.get("run_id", ""))
    record.duration_seconds = float(data.get("duration_seconds", 0.0))
    record.waves_completed = int(data.get("waves_completed", 0))
    record.damage_dealt = int(data.get("damage_dealt", 0))
    record.traps_triggered = int(data.get("traps_triggered", 0))
    record.monsters_lost = int(data.get("monsters_lost", 0))
    record.treasure_protected = bool(data.get("treasure_protected", false))
    record.victory = bool(data.get("victory", false))
    record.difficulty_id = str(data.get("difficulty_id", "normal"))
    return record
