class_name DifficultyDirector
extends RefCounted

enum Level { STORY, NORMAL, HARD, NIGHTMARE }

const PROFILES := {
    Level.STORY: {"health": 0.8, "damage": 0.75, "speed": 0.95, "reward": 0.8, "elite_rate": 0.0},
    Level.NORMAL: {"health": 1.0, "damage": 1.0, "speed": 1.0, "reward": 1.0, "elite_rate": 0.08},
    Level.HARD: {"health": 1.3, "damage": 1.2, "speed": 1.08, "reward": 1.35, "elite_rate": 0.16},
    Level.NIGHTMARE: {"health": 1.65, "damage": 1.45, "speed": 1.15, "reward": 1.75, "elite_rate": 0.25},
}

const ELITE_AFFIXES := ["armored", "swift", "regenerating", "treasure_hunter"]
const NAMED_PROFILES := {
    &"discovery": {"level": Level.STORY, "starting_gold": 25, "mistake_tolerance": 2, "hidden_rules": false},
    &"architect": {"level": Level.NORMAL, "starting_gold": 0, "mistake_tolerance": 1, "hidden_rules": false},
    &"ruthless": {"level": Level.HARD, "starting_gold": -15, "mistake_tolerance": 0, "hidden_rules": false},
}

var selected_profile: StringName = &"architect"

func profile(level: Level) -> Dictionary:
    return PROFILES.get(level, PROFILES[Level.NORMAL]).duplicate(true)

func scaled_stats(base_stats: Dictionary, level: Level, wave: int) -> Dictionary:
    var result := base_stats.duplicate(true)
    var rules: Dictionary = profile(level)
    var wave_scale := 1.0 + maxf(float(wave - 1), 0.0) * 0.06
    result["max_health"] = float(base_stats.get("max_health", 1.0)) * float(rules.health) * wave_scale
    result["attack"] = float(base_stats.get("attack", 1.0)) * float(rules.damage) * wave_scale
    result["speed"] = float(base_stats.get("speed", 1.0)) * float(rules.speed)
    return result

func should_spawn_elite(level: Level, wave: int, roll: float) -> bool:
    if wave < 3:
        return false
    var base_rate := float(profile(level).elite_rate)
    if base_rate <= 0.0:
        return false
    var chance := base_rate + float(wave - 3) * 0.015
    return roll < clampf(chance, 0.0, 0.6)

func elite_affix(seed_value: int, wave: int) -> String:
    return ELITE_AFFIXES[posmod(seed_value + wave, ELITE_AFFIXES.size())]

func boss_phase(health_ratio: float) -> int:
    if health_ratio <= 0.33:
        return 3
    if health_ratio <= 0.66:
        return 2
    return 1

func boss_modifiers(phase: int) -> Dictionary:
    match phase:
        3:
            return {"damage": 1.45, "speed": 1.2, "summon_count": 3, "shield": false}
        2:
            return {"damage": 1.2, "speed": 1.1, "summon_count": 2, "shield": false}
        _:
            return {"damage": 1.0, "speed": 1.0, "summon_count": 0, "shield": true}

func select_profile(id: StringName) -> bool:
    if not NAMED_PROFILES.has(id):
        return false
    selected_profile = id
    return true

func selected_rules() -> Dictionary:
    return NAMED_PROFILES[selected_profile].duplicate(true)

func balance_report(samples: Array[Dictionary]) -> Dictionary:
    if samples.is_empty():
        return {"ok": false, "alerts": ["no_samples"]}
    var victories := samples.filter(func(sample: Dictionary): return bool(sample.get("victory", false))).size()
    var insoluble := samples.filter(func(sample: Dictionary): return not bool(sample.get("solvable", true))).size()
    var trap_ids := {}
    var monster_ids := {}
    for sample in samples:
        for id in sample.get("trap_ids", []):
            trap_ids[id] = int(trap_ids.get(id, 0)) + 1
        for id in sample.get("monster_ids", []):
            monster_ids[id] = int(monster_ids.get(id, 0)) + 1
    var win_rate := float(victories) / float(samples.size())
    var alerts: Array[String] = []
    if insoluble > 0:
        alerts.append("insoluble_seeds")
    if win_rate < 0.15 or win_rate > 0.9:
        alerts.append("win_rate_outlier")
    if trap_ids.size() < 2:
        alerts.append("trap_diversity_low")
    if monster_ids.size() < 2:
        alerts.append("monster_diversity_low")
    return {"ok": alerts.is_empty(), "win_rate": win_rate, "insoluble": insoluble, "alerts": alerts}

func to_dict() -> Dictionary:
    return {"selected_profile": selected_profile}

func from_dict(data: Dictionary) -> void:
    select_profile(StringName(data.get("selected_profile", &"architect")))
