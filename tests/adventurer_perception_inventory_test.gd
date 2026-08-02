extends SceneTree

func _init() -> void:
    var perception := AdventurerPerception.new()
    perception.configure_for_class("thief")
    var blocked: Array[Vector2i] = [Vector2i(2, 0)]
    var visible := perception.visible_cells(Vector2i.ZERO, blocked)
    assert(visible.has(Vector2i(1, 0)))
    assert(not visible.has(Vector2i(3, 0)))

    perception.apply_threat(40.0, 60.0)
    assert(perception.decision_state() == "cautious")
    perception.apply_threat(40.0, 30.0)
    assert(perception.decision_state() == "flee")

    var inventory := AdventurerInventory.new()
    assert(inventory.add("potion"))
    assert(inventory.add("key"))
    assert(inventory.add("smoke_bomb"))
    assert(not inventory.add("torch"))
    assert(inventory.best_item_for("escape", 1.0, 80.0) == "smoke_bomb")

    var decision_engine := AdventurerDecisionEngine.new()
    var flee_decision := decision_engine.choose_action("thief", perception, inventory, {"health_ratio": 0.9, "exit_visible": true})
    assert(flee_decision.action == "use_item")
    assert(flee_decision.item == "smoke_bomb")

    perception.fear = 0.0
    perception.morale = 100.0
    var key_decision := decision_engine.choose_action("thief", perception, inventory, {"health_ratio": 1.0, "locked_door": true})
    assert(key_decision.action == "use_item")
    assert(key_decision.item == "key")

    var combat_decision := decision_engine.choose_action("warrior", perception, inventory, {"health_ratio": 0.8, "nearby_threats": 2})
    assert(combat_decision.action == "fight")
    assert(combat_decision.style == "nearest")

    var restored_perception := AdventurerPerception.new()
    restored_perception.from_dict(perception.to_dict())
    assert(restored_perception.vision_range == perception.vision_range)
    var restored_inventory := AdventurerInventory.new()
    restored_inventory.from_dict(inventory.to_dict())
    assert(restored_inventory.items == inventory.items)

    print("adventurer perception inventory test passed")
    quit()
