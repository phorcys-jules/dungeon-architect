extends SceneTree

func _init() -> void:
    var world_map := RogueliteWorldMap.new()
    world_map.generate(42, 6, 3)
    assert(world_map.columns.size() == 6)
    assert(world_map.columns[5].size() == 1)
    assert(int(world_map.columns[5][0].type) == RogueliteWorldMap.NodeType.BOSS)
    var first_choices := world_map.available_nodes()
    assert(first_choices.size() == 3)
    assert(world_map.choose(String(first_choices[0].id)))
    assert(world_map.visited.size() == 1)
    var restored_map := RogueliteWorldMap.new()
    restored_map.from_dict(world_map.to_dict())
    assert(restored_map.current_node_id == world_map.current_node_id)

    var merchant := MerchantInventory.new()
    var stock := merchant.roll_stock(99, 3)
    assert(stock.size() == 3)
    var same_stock := MerchantInventory.new().roll_stock(99, 3)
    assert(same_stock == stock)
    var offer: Dictionary = stock[0]
    assert(not merchant.can_buy(String(offer.id), int(offer.price) - 1))
    var purchase := merchant.buy(String(offer.id), int(offer.price))
    assert(purchase.ok)
    assert(int(purchase.gold_delta) == -int(offer.price))
    assert(not merchant.buy(String(offer.id), 999).ok)
    var restored_merchant := MerchantInventory.new()
    restored_merchant.from_dict(merchant.to_dict())
    assert(restored_merchant.purchased.has(String(offer.id)))

    print("roguelite map and merchant test passed")
    quit()
