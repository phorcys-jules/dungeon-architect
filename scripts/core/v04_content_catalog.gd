class_name V04ContentCatalog
extends RefCounted

func adventurers() -> Array[AdventurerProfileData]:
    return [
        _adventurer(&"thief", "Voleur", 1.25, 0.8, &"steal", [&"agile"], {"gold_priority": 1.5}),
        _adventurer(&"mage", "Mage", 0.9, 0.9, &"teleport", [&"magic"], {"teleport_cooldown": 8.0}),
        _adventurer(&"priest", "Prêtre", 0.95, 1.1, &"purify", [&"holy"], {"trap_resistance": 0.35}),
        _adventurer(&"berserker", "Berserker", 1.05, 1.4, &"rage", [&"warrior"], {"rage_threshold": 0.4}),
    ]

func buildings() -> Array[VillageBuildingData]:
    return [
        _building(&"forge", "Forge", &"trap_damage_multiplier", 0.1, 60),
        _building(&"laboratory", "Laboratoire", &"effect_duration_multiplier", 0.12, 70),
        _building(&"graveyard", "Cimetière", &"monster_respawn_speed_multiplier", 0.15, 80),
    ]

func permanent_upgrades() -> Dictionary:
    return {
        &"swift_horde": {"name": "Horde véloce", "modifier": &"monster_speed_multiplier", "value": 0.08, "cost": 40},
        &"sharpened_traps": {"name": "Pièges affûtés", "modifier": &"trap_damage_multiplier", "value": 0.1, "cost": 45},
        &"greedy_goblins": {"name": "Gobelins cupides", "modifier": &"gold_multiplier", "value": 0.12, "cost": 50},
        &"larger_den": {"name": "Tanière agrandie", "modifier": &"monster_capacity", "value": 1.0, "cost": 70},
        &"reinforced_doors": {"name": "Portes renforcées", "modifier": &"door_cooldown_multiplier", "value": -0.1, "cost": 55},
        &"patient_hunters": {"name": "Chasseurs patients", "modifier": &"ambush_damage_multiplier", "value": 0.15, "cost": 65},
    }

func extra_synergies() -> Dictionary:
    return {
        &"spider_crossroads": {"name": "Toile stratégique", "required": [&"spider", &"junction"], "modifiers": {&"slow_duration_multiplier": 1.4}},
        &"ghost_portal": {"name": "Portail spectral", "required": [&"ghost", &"portal"], "modifiers": {&"monster_respawn_speed_multiplier": 1.3}},
        &"slime_curse": {"name": "Gelée maudite", "required": [&"slime", &"curse"], "modifiers": {&"adventurer_speed_multiplier": 0.8}},
    }

func mini_boss() -> Dictionary:
    return {"id": &"paladin_captain", "name": "Capitaine paladin", "health_multiplier": 4.0, "speed_multiplier": 0.9, "abilities": [&"holy_shield", &"monster_knockback"], "reward_multiplier": 2.0}

func migrate_save(data: Dictionary) -> Dictionary:
    var result := data.duplicate(true)
    result["save_version"] = 2
    if not result.has("buildings"):
        result["buildings"] = {"forge": 0, "laboratory": 0, "graveyard": 0}
    if not result.has("permanent_upgrades"):
        result["permanent_upgrades"] = {}
    if not result.has("unlocks"):
        result["unlocks"] = ["corridor", "crossroads", "treasure_hall"]
    return result

func _adventurer(id: StringName, name: String, speed: float, health: float, behaviour: StringName, tags: Array[StringName], parameters: Dictionary) -> AdventurerProfileData:
    var value := AdventurerProfileData.new()
    value.profile_id = id
    value.display_name = name
    value.speed_multiplier = speed
    value.health_multiplier = health
    value.behaviour = behaviour
    value.tags = tags
    value.parameters = parameters
    return value

func _building(id: StringName, name: String, bonus: StringName, value: float, cost: int) -> VillageBuildingData:
    var building := VillageBuildingData.new()
    building.building_id = id
    building.display_name = name
    building.bonus_key = bonus
    building.bonus_per_level = value
    building.base_cost = cost
    return building
