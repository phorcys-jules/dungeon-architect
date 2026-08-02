class_name AchievementTracker
extends RefCounted

var definitions := {
    "first_capture": {"name": "Première capture", "condition": "captures", "target": 1},
    "master_trapper": {"name": "Maître des pièges", "condition": "trap_kills", "target": 25},
    "untouchable_treasure": {"name": "Trésor intact", "condition": "perfect_runs", "target": 1},
    "family_reunion": {"name": "Réunion de famille", "condition": "family_team_runs", "target": 1},
    "endless_ten": {"name": "Dix vagues sans fin", "condition": "endless_wave", "target": 10},
    "endless_twenty_five": {"name": "Architecte éternel", "condition": "endless_wave", "target": 25},
}

var counters: Dictionary = {}
var unlocked: Array[String] = []
var pending_notifications: Array[String] = []

func add_progress(condition: String, amount: int = 1) -> Array[String]:
    counters[condition] = int(counters.get(condition, 0)) + maxi(amount, 0)
    var newly_unlocked: Array[String] = []
    for achievement_id in definitions:
        if unlocked.has(achievement_id):
            continue
        var definition: Dictionary = definitions[achievement_id]
        if String(definition.condition) == condition and int(counters[condition]) >= int(definition.target):
            unlocked.append(achievement_id)
            pending_notifications.append(achievement_id)
            newly_unlocked.append(achievement_id)
    return newly_unlocked

func is_unlocked(achievement_id: String) -> bool:
    return unlocked.has(achievement_id)

func consume_notifications() -> Array[String]:
    var result := pending_notifications.duplicate()
    pending_notifications.clear()
    return result

func progress(achievement_id: String) -> Dictionary:
    if not definitions.has(achievement_id):
        return {}
    var definition: Dictionary = definitions[achievement_id]
    var current := int(counters.get(String(definition.condition), 0))
    return {
        "current": current,
        "target": int(definition.target),
        "complete": unlocked.has(achievement_id),
    }

func to_dict() -> Dictionary:
    return {
        "counters": counters.duplicate(true),
        "unlocked": unlocked.duplicate(),
    }

func from_dict(data: Dictionary) -> void:
    counters = Dictionary(data.get("counters", {})).duplicate(true)
    unlocked.assign(data.get("unlocked", []))
    unlocked = unlocked.filter(func(id: String): return definitions.has(id))
    pending_notifications.clear()
