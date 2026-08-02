class_name MerchantInventory
extends RefCounted

var catalog := {
    "slime_recruit": {"kind": "monster", "name": "Recruter un slime", "price": 40},
    "spider_recruit": {"kind": "monster", "name": "Recruter une araignée", "price": 55},
    "trap_damage": {"kind": "upgrade", "name": "Pointes renforcées", "price": 45},
    "monster_health": {"kind": "upgrade", "name": "Chair robuste", "price": 50},
    "blood_crown": {"kind": "relic", "name": "Couronne de sang", "price": 80},
    "thorn_heart": {"kind": "relic", "name": "Cœur d'épines", "price": 75},
}

var stock: Array[Dictionary] = []
var purchased: Array[String] = []

func roll_stock(seed: int, count: int = 3) -> Array[Dictionary]:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed
    var ids: Array[String] = []
    ids.assign(catalog.keys())
    ids.shuffle()
    stock.clear()
    for index in mini(count, ids.size()):
        var id := ids[index]
        var offer: Dictionary = catalog[id].duplicate(true)
        offer["id"] = id
        offer["sold"] = false
        offer["price"] = maxi(int(offer.price) + rng.randi_range(-5, 10), 1)
        stock.append(offer)
    return stock.duplicate(true)

func can_buy(offer_id: String, available_gold: int) -> bool:
    var offer := get_offer(offer_id)
    return not offer.is_empty() and not bool(offer.sold) and available_gold >= int(offer.price)

func buy(offer_id: String, available_gold: int) -> Dictionary:
    if not can_buy(offer_id, available_gold):
        return {"ok": false, "gold_delta": 0, "reward": {}}
    for offer in stock:
        if offer.id == offer_id:
            offer.sold = true
            purchased.append(offer_id)
            return {
                "ok": true,
                "gold_delta": -int(offer.price),
                "reward": {"id": offer_id, "kind": offer.kind},
            }
    return {"ok": false, "gold_delta": 0, "reward": {}}

func get_offer(offer_id: String) -> Dictionary:
    for offer in stock:
        if offer.id == offer_id:
            return offer
    return {}

func to_dict() -> Dictionary:
    return {"stock": stock.duplicate(true), "purchased": purchased.duplicate()}

func from_dict(data: Dictionary) -> void:
    stock.assign(data.get("stock", []))
    purchased.assign(data.get("purchased", []))
