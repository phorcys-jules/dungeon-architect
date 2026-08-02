extends SceneTree

func _init() -> void:
    var market := VillageBlackMarket.new()
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

    print("village black market test passed")
    quit()
