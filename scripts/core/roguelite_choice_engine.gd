class_name RogueliteChoiceEngine
extends RefCounted

const CHOICES := [
    {"id": &"monster_speed", "label": "Monstres véloces", "description": "+15 % de vitesse pour tous les monstres.", "modifiers": {"monster_speed_multiplier": 0.15}},
    {"id": &"trap_power", "label": "Pièges renforcés", "description": "+20 % de dégâts pour tous les pièges.", "modifiers": {"trap_damage_multiplier": 0.20}},
    {"id": &"door_mastery", "label": "Mécanismes huilés", "description": "La porte peut être actionnée 20 % plus souvent.", "modifiers": {"door_cooldown_multiplier": -0.20}},
    {"id": &"resource_bonus", "label": "Butin maudit", "description": "+15 % d'or gagné à la fin des vagues.", "modifiers": {"permanent_reward_multiplier": 0.15}},
    {"id": &"fog", "label": "Brume hantée", "description": "Active Voile spectral et réduit encore de 10 % les dégâts reçus par le fantôme.", "modifiers": {"ghost_evasion": 0.10}, "tags": [&"fog"]},
    {"id": &"ice", "label": "Sol gelé", "description": "Active Patinoire visqueuse et renforce de 10 % le ralentissement du slime.", "modifiers": {"enemy_slow": 0.10}, "tags": [&"ice"]},
    {"id": &"treasure", "label": "Faux trésor", "description": "Active Trésor piégé et ajoute 15 % de dégâts à l'embuscade du mimic.", "modifiers": {"ambush_damage": 0.15}, "tags": [&"treasure"]},
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
