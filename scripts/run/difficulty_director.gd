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
    var chance := float(profile(level).elite_rate) + float(wave - 3) * 0.015
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
