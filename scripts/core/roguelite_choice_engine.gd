class_name RogueliteChoiceEngine
extends RefCounted

const CHOICES := [
    {"id": &"monster_speed", "label": "Monstres véloces", "modifiers": {"monster_speed_multiplier": 0.15}},
    {"id": &"trap_power", "label": "Pointes renforcées", "modifiers": {"trap_damage_multiplier": 0.20}},
    {"id": &"door_mastery", "label": "Mécanismes huilés", "modifiers": {"door_cooldown_multiplier": -0.20}},
    {"id": &"resource_bonus", "label": "Butin maudit", "modifiers": {"permanent_reward_multiplier": 0.15}},
    {"id": &"fog", "label": "Brume hantée", "tags": [&"fog"]},
    {"id": &"ice", "label": "Sol gelé", "tags": [&"ice"]},
    {"id": &"treasure", "label": "Faux trésor", "tags": [&"treasure"]},
]

func offer(seed_value: int, wave_index: int, count: int = 3) -> Array[Dictionary]:
    var pool: Array[Dictionary] = []
    for choice: Dictionary in CHOICES:
        pool.append(choice.duplicate(true))
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value + wave_index * 7919
    for index: int in range(pool.size() - 1, 0, -1):
        var swap_index := rng.randi_range(0, index)
        var temporary := pool[index]
        pool[index] = pool[swap_index]
        pool[swap_index] = temporary
    return pool.slice(0, mini(count, pool.size()))
