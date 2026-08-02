class_name SynergyCatalog
extends RefCounted

var entries: Array[Dictionary] = [
    {"id":"ghost_fog","name":"Voile spectral","description":"Dans le brouillard, le fantôme subit 20 % de dégâts en moins.","requires":["monster:ghost","room:fog"],"effect":{"evasion":0.20}},
    {"id":"slime_ice","name":"Patinoire visqueuse","description":"Les zones de slime ralentissent les aventuriers 25 % plus fortement.","requires":["monster:slime","room:ice"],"effect":{"enemy_slow":0.25}},
    {"id":"mimic_treasure","name":"Trésor piégé","description":"La première embuscade du mimic inflige 35 % de dégâts supplémentaires.","requires":["monster:mimic","room:treasure"],"effect":{"ambush_damage":0.35}},
    {"id":"spider_web","name":"Nid de soie","requires":["monster:spider","trap:web"],"effect":{"root_duration":1.5}},
    {"id":"goblin_forge","name":"Armement gobelin","requires":["monster:goblin","building:forge"],"effect":{"monster_damage":0.15}},
    {"id":"skeleton_crypt","name":"Légion des cryptes","requires":["monster:skeleton","biome:crypt"],"effect":{"respawn_chance":0.18}},
    {"id":"bat_darkness","name":"Chasse nocturne","requires":["monster:bat","event:darkness"],"effect":{"move_speed":0.18}},
    {"id":"door_thorns","name":"Seuil d'épines","requires":["door:locked","relic:thorn_heart"],"effect":{"door_retaliation":12}},
    {"id":"poison_sewer","name":"Miasmes toxiques","requires":["trap:poison","biome:sewer"],"effect":{"poison_duration":2.0}},
    {"id":"guardian_crown","name":"Garde royale","requires":["role:guardian","relic:blood_crown"],"effect":{"treasure_guard":0.25}},
]

func all() -> Array[Dictionary]:
    return entries.duplicate(true)

func get_entry(id: String) -> Dictionary:
    for entry in entries:
        if entry.id == id:
            return entry.duplicate(true)
    return {}
