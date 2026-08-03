class_name TacticalDebriefRuntime
extends RefCounted

const MAX_FINDINGS := 3

var last_report: Dictionary = {}

func analyze(summary: Dictionary, replay: ReplayTimeline) -> Dictionary:
    var findings: Array[Dictionary] = []
    var heatmap: Dictionary = summary.get("tactical_heatmap", {})
    var damage_taken := int(summary.get("damage_taken", 0))
    var captures := int(summary.get("captures", 0))
    var stole_treasure := bool(summary.get("stole_treasure", false))
    if stole_treasure:
        findings.append(_finding(&"treasure_exposed", 100, replay, [&"run_end", &"steal"]))
    if damage_taken > 75:
        findings.append(_finding(&"defense_breached", mini(damage_taken, 99), replay, [&"attack", &"sabotage"]))
    if captures == 0 and not bool(summary.get("victory", false)):
        findings.append(_finding(&"monsters_isolated", 60, replay, [&"wave_start"]))
    if heatmap.is_empty() and not bool(summary.get("victory", false)):
        findings.append(_finding(&"untracked_route", 40, replay, [&"run_start"]))
    findings.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.impact) > int(b.impact))
    if findings.size() > MAX_FINDINGS:
        findings.resize(MAX_FINDINGS)
    last_report = {"victory": bool(summary.get("victory", false)), "findings": findings, "seed": replay.seed}
    return last_report.duplicate(true)

func _finding(id: StringName, impact: int, replay: ReplayTimeline, event_types: Array[StringName]) -> Dictionary:
    var evidence := {}
    for index in replay.events.size():
        var event: Dictionary = replay.events[index]
        if event_types.has(StringName(event.type)):
            evidence = {"event_index": index, "time": event.t, "cell": event.cell}
            break
    return {"id": id, "impact": impact, "text_key": "debrief.%s" % id, "evidence": evidence}

func to_dict() -> Dictionary:
    return last_report.duplicate(true)

func from_dict(data: Dictionary) -> void:
    last_report = data.duplicate(true)
