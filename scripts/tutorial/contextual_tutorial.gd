class_name ContextualTutorial
extends RefCounted

const STEPS := [&"place_defense", &"inspect_path", &"place_trap", &"place_monster", &"toggle_door", &"start_wave"]
var seen: Array[StringName] = []
var sandbox := false

func next_hint(event: StringName) -> Dictionary:
    if not STEPS.has(event) or seen.has(event):
        return {}
    seen.append(event)
    return {"step": event, "text": _description(event), "codex": "tutorial/%s" % event, "skippable": true}

func reset() -> void:
    seen.clear()

func is_complete() -> bool:
    return seen.size() == STEPS.size()

func set_sandbox(enabled: bool) -> void:
    sandbox = enabled

func may_persist_rewards() -> bool:
    return not sandbox

func serialize() -> Dictionary:
    return {"seen": seen.duplicate(), "sandbox": sandbox}

func restore(data: Dictionary) -> void:
    seen.clear()
    for value in data.get("seen", []):
        var step := StringName(value)
        if STEPS.has(step) and not seen.has(step):
            seen.append(step)
    sandbox = bool(data.get("sandbox", false))

func _description(step: StringName) -> String:
    return {
        &"place_defense": "Placez une défense sur une case libre.",
        &"inspect_path": "Vérifiez que le trésor reste accessible.",
        &"place_trap": "Ajoutez un piège sur la route probable.",
        &"place_monster": "Placez un monstre pour intercepter l'équipe.",
        &"toggle_door": "Utilisez la porte pour détourner l'invasion.",
        &"start_wave": "Lancez la vague lorsque votre plan est prêt.",
    }.get(step, "")
