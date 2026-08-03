class_name RunPerformanceCalculator
extends RefCounted

const DIFFICULTY_MULTIPLIERS := {
    "easy": 0.8,
    "discovery": 0.8,
    "normal": 1.0,
    "architect": 1.0,
    "hard": 1.35,
    "ruthless": 1.35,
}

func calculate(record: RunResultRecord) -> Dictionary:
    var score := record.waves_completed * 100
    score += record.damage_dealt / 10
    score += record.traps_triggered * 15
    score -= record.monsters_lost * 30
    if record.treasure_protected:
        score += 300
    if record.victory:
        score += 200
    score = maxi(score, 0)
    var multiplier := float(DIFFICULTY_MULTIPLIERS.get(record.difficulty_id, 1.0))
    var final_score := int(round(score * multiplier))
    return {
        "score": final_score,
        "gold": int(round(final_score * 0.12)),
        "essence": int(round(final_score * 0.035)),
        "difficulty_multiplier": multiplier,
    }
