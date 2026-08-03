class_name GuidedCampaignRuntime
extends RefCounted

const SEED := 808080
const STEPS := [&"choose_route", &"place_wall", &"place_trap", &"assign_monster", &"start_wave", &"review_result", &"upgrade_village"]

var completed: Array[StringName] = []
var enabled := true

func current() -> Dictionary:
    if not enabled or is_complete():
        return {}
    var step: StringName = STEPS[completed.size()]
    return {"id": step, "text_key": "tutorial.%s" % step, "skippable": true, "seed": SEED}

func observe(event: StringName) -> bool:
    var current_step := current()
    if current_step.is_empty() or StringName(current_step.id) != event:
        return false
    completed.append(event)
    return true

func skip() -> void:
    enabled = false

func restart() -> void:
    completed.clear()
    enabled = true

func is_complete() -> bool:
    return completed.size() == STEPS.size()

func to_dict() -> Dictionary:
    return {"completed": completed.duplicate(), "enabled": enabled}

func from_dict(data: Dictionary) -> void:
    completed.clear()
    for value in data.get("completed", []):
        var step := StringName(value)
        if STEPS.has(step) and not completed.has(step):
            completed.append(step)
    enabled = bool(data.get("enabled", true))
