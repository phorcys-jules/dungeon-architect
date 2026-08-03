extends SceneTree

func _init() -> void:
    var market := VillageBlackMarket.new()
    assert(market.catalog_is_fully_wired())
    var first_stock := market.refresh(42, 3)
    assert(first_stock.size() == 3)
    var first_offer: Dictionary = first_stock[0]
    var price := int(first_offer.price)
    assert(not market.can_buy(String(first_offer.id), price - 1))
    var purchase := market.buy(String(first_offer.id), price)
    assert(bool(purchase.ok))
    assert(int(purchase.gold_delta) == -price)
    assert(not Dictionary(purchase.curse).is_empty())
    assert(not market.buy(String(first_offer.id), 9999).ok)
    assert(market.active_curses.size() == 1)

    var next_stock := market.refresh(42, 3)
    assert(next_stock.size() == 3)
    assert(market.refresh_index == 2)

    var restored := VillageBlackMarket.new()
    restored.from_dict(market.to_dict())
    assert(restored.refresh_index == market.refresh_index)
    assert(restored.purchased_ids == market.purchased_ids)
    assert(restored.active_curses.size() == 1)

    var linked_market := VillageBlackMarket.new()
    linked_market.purchased_ids = ["wraith_recruit", "bone_foundry", "blood_contract"]
    linked_market.active_curses = [{"id": "elite_hunters"}, {"id": "monster_upkeep", "monster_upkeep_bonus": 1}]
    var modifiers := linked_market.combined_modifiers()
    assert(is_equal_approx(float(modifiers.monster_health_multiplier), 0.25))
    assert(is_equal_approx(float(modifiers.trap_damage_multiplier), 0.25))
    assert(is_equal_approx(float(modifiers.defender_damage_multiplier), 0.30))
    assert(is_equal_approx(float(modifiers.adventurer_health_multiplier), 0.12))
    assert(int(modifiers.starting_gold_adjustment) == -10)
    assert(linked_market.active_effect_summaries().size() == 5)

    print("village black market test passed")
    quit()
