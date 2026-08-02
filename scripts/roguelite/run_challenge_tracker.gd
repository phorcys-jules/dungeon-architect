class_name RunChallengeTracker
extends RefCounted

var catalog := RunChallengeCatalog.new()
var active: Array[String] = []
var metrics: Dictionary = {}
var completed: Array[String] = []
var claimed: Array[String] = []

func start(challenge_ids: Array[String]) -> bool:
    var unique: Array[String] = []
    for challenge_id in challenge_ids:
        if catalog.get_definition(challenge_id).is_empty() or unique.has(challenge_id):
            return false
        unique.append(challenge_id)
    active = unique
    metrics.clear()
    completed.clear()
    claimed.clear()
    return not active.is_empty()

func set_metric(metric: String, value: float) -> void:
    metrics[metric] = value
    _refresh_completion()

func increment(metric: String, amount: float = 1.0) -> void:
    metrics[metric] = float(metrics.get(metric, 0.0)) + amount
    _refresh_completion()

func is_completed(challenge_id: String) -> bool:
    return completed.has(challenge_id)

func progress(challenge_id: String) -> Dictionary:
    var definition := catalog.get_definition(challenge_id)
    if definition.is_empty():
        return {}
    var current := float(metrics.get(String(definition.metric), 0.0))
    return {
        "id": challenge_id,
        "name": definition.name,
        "current": current,
        "target": float(definition.target),
        "completed": completed.has(challenge_id),
    }

func claim(challenge_id: String, difficulty_multiplier: float = 1.0) -> Dictionary:
    if not completed.has(challenge_id) or claimed.has(challenge_id):
        return {"ok": false, "gold": 0, "essence": 0}
    var definition := catalog.get_definition(challenge_id)
    claimed.append(challenge_id)
    return {
        "ok": true,
        "gold": roundi(float(definition.reward.gold) * maxf(difficulty_multiplier, 0.0)),
        "essence": roundi(float(definition.reward.essence) * maxf(difficulty_multiplier, 0.0)),
    }

func to_dict() -> Dictionary:
    return {
        "active": active.duplicate(),
        "metrics": metrics.duplicate(true),
        "completed": completed.duplicate(),
        "claimed": claimed.duplicate(),
    }

func from_dict(data: Dictionary) -> void:
    active.assign(data.get("active", []))
    active = active.filter(func(id: String): return not catalog.get_definition(id).is_empty())
    metrics = Dictionary(data.get("metrics", {})).duplicate(true)
    completed.assign(data.get("completed", []))
    completed = completed.filter(func(id: String): return active.has(id))
    claimed.assign(data.get("claimed", []))
    claimed = claimed.filter(func(id: String): return completed.has(id))
    _refresh_completion()

func _refresh_completion() -> void:
    for challenge_id in active:
        if completed.has(challenge_id):
            continue
        var definition := catalog.get_definition(challenge_id)
        if _matches(definition) and _requirements_match(definition.get("requires", {})):
            completed.append(challenge_id)

func _matches(definition: Dictionary) -> bool:
    var current := float(metrics.get(String(definition.metric), 0.0))
    var target := float(definition.target)
    match String(definition.comparison):
        "equal":
            return is_equal_approx(current, target)
        "max":
            return current <= target
        "min":
            return current >= target
        _:
            return false

func _requirements_match(requirements: Dictionary) -> bool:
    for metric in requirements:
        if float(metrics.get(metric, 0.0)) < float(requirements[metric]):
            return false
    return true
