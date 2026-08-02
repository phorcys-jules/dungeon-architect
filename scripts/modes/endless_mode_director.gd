class_name EndlessModeDirector
extends RefCounted

var seed := 0
var wave := 0
var score := 0
var best_score := 0
var active_modifiers: Array[String] = []

var modifier_pool: Array[String] = [
    "armored_adventurers",
    "faster_traps",
    "elite_surge",
    "darkness",
    "healing_reduction",
    "double_rewards",
]

func start(run_seed: int, stored_best_score: int = 0) -> void:
    seed = run_seed
    wave = 0
    score = 0
    best_score = maxi(stored_best_score, 0)
    active_modifiers.clear()

func next_wave() -> Dictionary:
    wave += 1
    if wave % 5 == 0:
        _unlock_modifier()
    var stat_multiplier := 1.0 + float(wave - 1) * 0.08
    var elite_chance := minf(0.05 + float(wave - 1) * 0.02, 0.75)
    var adventurer_count := 1 + int(floor(float(wave - 1) / 4.0))
    return {
        "wave": wave,
        "stat_multiplier": stat_multiplier,
        "elite_chance": elite_chance,
        "adventurer_count": adventurer_count,
        "modifiers": active_modifiers.duplicate(),
    }

func complete_wave(captures: int, treasure_health: int, elapsed_seconds: float) -> int:
    var speed_bonus := maxi(300 - int(elapsed_seconds * 5.0), 0)
    var gained := 100 * wave + maxi(captures, 0) * 75 + maxi(treasure_health, 0) * 2 + speed_bonus
    score += gained
    best_score = maxi(best_score, score)
    return gained

func share_seed() -> String:
    return "DA-ENDLESS-%d" % seed

func to_dict() -> Dictionary:
    return {
        "seed": seed,
        "wave": wave,
        "score": score,
        "best_score": best_score,
        "active_modifiers": active_modifiers.duplicate(),
    }

func from_dict(data: Dictionary) -> void:
    seed = int(data.get("seed", 0))
    wave = maxi(int(data.get("wave", 0)), 0)
    score = maxi(int(data.get("score", 0)), 0)
    best_score = maxi(int(data.get("best_score", 0)), score)
    active_modifiers.assign(data.get("active_modifiers", []))
    active_modifiers = active_modifiers.filter(func(id: String): return modifier_pool.has(id))

func _unlock_modifier() -> void:
    var available := modifier_pool.filter(func(id: String): return not active_modifiers.has(id))
    if available.is_empty():
        return
    var rng := RandomNumberGenerator.new()
    rng.seed = seed + wave * 7919
    active_modifiers.append(String(available[rng.randi_range(0, available.size() - 1)]))
