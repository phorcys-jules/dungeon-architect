class_name TutorialProgress
extends RefCounted

const STEPS := ["prepare_dungeon", "start_invasion", "observe_combat", "protect_treasure", "spend_rewards"]

var completed: Array[String] = []

func current_step() -> String:
    for step in STEPS:
        if not completed.has(step):
            return step
    return "complete"

func complete(step: String) -> bool:
    if not STEPS.has(step):
        return false
    if not completed.has(step):
        completed.append(step)
    return true

func is_complete() -> bool:
    return completed.size() == STEPS.size()

func serialize() -> Dictionary:
    return {"completed": completed.duplicate()}

func restore(data: Dictionary) -> void:
    completed.clear()
    for value in data.get("completed", []):
        var step := str(value)
        if STEPS.has(step) and not completed.has(step):
            completed.append(step)
