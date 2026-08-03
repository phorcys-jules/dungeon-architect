class_name VillageBlackMarket
extends RefCounted

const OFFER_CATALOG := {
    "wraith_recruit": {
        "kind": "monster",
        "name": "Recruter un spectre ancien",
        "base_price": 120,
        "rarity": "rare",
        "curse": {"id": "fragile_walls", "wall_health_multiplier": 0.85},
    },
    "mimic_room": {
        "kind": "room",
        "name": "Salle mimic affamée",
        "base_price": 105,
        "rarity": "rare",
        "curse": {"id": "greedy_chest", "treasure_channel_multiplier": 0.90},
    },
    "void_crown": {
        "kind": "relic",
        "name": "Couronne du vide",
        "base_price": 160,
        "rarity": "legendary",
        "curse": {"id": "elite_hunters", "elite_chance_bonus": 0.08},
    },
    "bone_foundry": {
        "kind": "building",
        "name": "Fonderie d'os clandestine",
        "base_price": 140,
        "rarity": "legendary",
        "curse": {"id": "taxed_essence", "essence_reward_multiplier": 0.80},
    },
    "blood_contract": {
        "kind": "upgrade",
        "name": "Contrat de sang",
        "base_price": 90,
        "rarity": "rare",
        "curse": {"id": "monster_upkeep", "monster_upkeep_bonus": 1},
    },
}

const PURCHASE_MODIFIERS := {
    "wraith_recruit": {"monster_health_multiplier": 0.25},
    "mimic_room": {"monster_damage_multiplier": 0.15},
    "void_crown": {"monster_damage_multiplier": 0.25},
    "bone_foundry": {"trap_damage_multiplier": 0.25},
    "blood_contract": {"defender_damage_multiplier": 0.30},
}

const CURSE_MODIFIERS := {
    "fragile_walls": {"starting_gold_adjustment": -10.0},
    "greedy_chest": {"adventurer_speed_multiplier": 0.10},
    "elite_hunters": {"adventurer_health_multiplier": 0.12},
    "taxed_essence": {"starting_gold_adjustment": -15.0},
    "monster_upkeep": {"starting_gold_adjustment": -10.0},
}

var refresh_index: int = 0
var stock: Array[Dictionary] = []
var purchased_ids: Array[String] = []
var active_curses: Array[Dictionary] = []

func refresh(seed: int, count: int = 3) -> Array[Dictionary]:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed + refresh_index * 7919
    refresh_index += 1
    var ids: Array[String] = []
    ids.assign(OFFER_CATALOG.keys())
    ids.shuffle()
    stock.clear()
    for index in mini(count, ids.size()):
        var id := ids[index]
        var offer: Dictionary = OFFER_CATALOG[id].duplicate(true)
        offer["id"] = id
        offer["price"] = maxi(1, int(round(float(offer.base_price) * rng.randf_range(0.90, 1.20))))
        offer["sold"] = false
        stock.append(offer)
    return stock.duplicate(true)

func can_buy(offer_id: String, available_gold: int) -> bool:
    var offer := get_offer(offer_id)
    return not offer.is_empty() and not bool(offer.get("sold", false)) and available_gold >= int(offer.price)

func buy(offer_id: String, available_gold: int) -> Dictionary:
    if not can_buy(offer_id, available_gold):
        return {"ok": false, "gold_delta": 0, "reward": {}, "curse": {}}
    for offer in stock:
        if String(offer.id) != offer_id:
            continue
        offer.sold = true
        purchased_ids.append(offer_id)
        var curse: Dictionary = offer.get("curse", {}).duplicate(true)
        active_curses.append(curse)
        return {
            "ok": true,
            "gold_delta": -int(offer.price),
            "reward": {"id": offer_id, "kind": String(offer.kind), "rarity": String(offer.rarity)},
            "curse": curse,
        }
    return {"ok": false, "gold_delta": 0, "reward": {}, "curse": {}}

func get_offer(offer_id: String) -> Dictionary:
    for offer in stock:
        if String(offer.id) == offer_id:
            return offer
    return {}

func to_dict() -> Dictionary:
    return {
        "refresh_index": refresh_index,
        "stock": stock.duplicate(true),
        "purchased_ids": purchased_ids.duplicate(),
        "active_curses": active_curses.duplicate(true),
    }

func from_dict(data: Dictionary) -> void:
    refresh_index = int(data.get("refresh_index", 0))
    stock.assign(data.get("stock", []))
    purchased_ids.assign(data.get("purchased_ids", []))
    active_curses.assign(data.get("active_curses", []))

func combined_modifiers() -> Dictionary:
    var result := {
        "trap_damage_multiplier": 0.0,
        "defender_damage_multiplier": 0.0,
        "monster_damage_multiplier": 0.0,
        "monster_health_multiplier": 0.0,
        "adventurer_health_multiplier": 0.0,
        "adventurer_speed_multiplier": 0.0,
        "starting_gold_adjustment": 0,
    }
    for purchase_id in purchased_ids:
        _merge_modifiers(result, PURCHASE_MODIFIERS.get(purchase_id, {}))
    for curse in active_curses:
        var curse_id := String(curse.get("id", ""))
        var modifier: Dictionary = CURSE_MODIFIERS.get(curse_id, {}).duplicate()
        if curse_id == "monster_upkeep":
            modifier.starting_gold_adjustment *= int(curse.get("monster_upkeep_bonus", 1))
        _merge_modifiers(result, modifier)
    return result

func active_effect_summaries() -> Array[String]:
    var lines: Array[String] = []
    for purchase_id in purchased_ids:
        if OFFER_CATALOG.has(purchase_id):
            lines.append("Pacte permanent — %s : %s" % [String(OFFER_CATALOG[purchase_id].name), _format_modifiers(PURCHASE_MODIFIERS.get(purchase_id, {}))])
    for curse in active_curses:
        var curse_id := String(curse.get("id", ""))
        var modifier: Dictionary = CURSE_MODIFIERS.get(curse_id, {}).duplicate()
        if curse_id == "monster_upkeep":
            modifier.starting_gold_adjustment *= int(curse.get("monster_upkeep_bonus", 1))
        lines.append("Malédiction permanente — %s" % _format_modifiers(modifier))
    return lines

func catalog_is_fully_wired() -> bool:
    for offer_id in OFFER_CATALOG:
        if not PURCHASE_MODIFIERS.has(offer_id) or not CURSE_MODIFIERS.has(String(OFFER_CATALOG[offer_id].curse.id)):
            return false
    return true

func _merge_modifiers(target: Dictionary, source: Dictionary) -> void:
    for key in source:
        target[key] = float(target.get(key, 0.0)) + float(source[key])

func _format_modifiers(modifiers: Dictionary) -> String:
    var labels := {"trap_damage_multiplier": "dégâts des pièges", "defender_damage_multiplier": "dégâts des défenseurs", "monster_damage_multiplier": "dégâts des monstres", "monster_health_multiplier": "santé des monstres", "adventurer_health_multiplier": "santé des aventuriers", "adventurer_speed_multiplier": "vitesse des aventuriers", "starting_gold_adjustment": "or initial"}
    var parts: Array[String] = []
    for key in modifiers:
        var value := float(modifiers[key])
        var shown := "%+d" % roundi(value) if key == "starting_gold_adjustment" else "%+d%%" % roundi(value * 100.0)
        parts.append("%s %s" % [shown, String(labels.get(key, key))])
    return ", ".join(parts)
