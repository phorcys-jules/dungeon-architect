class_name AdventurerDecisionEngine
extends RefCounted

func choose_action(class_id: String, perception: AdventurerPerception, inventory: AdventurerInventory, context: Dictionary) -> Dictionary:
    var state := perception.decision_state()
    var health_ratio := float(context.get("health_ratio", 1.0))
    var nearby_threats := int(context.get("nearby_threats", 0))
    var locked_door := bool(context.get("locked_door", false))
    var darkness := bool(context.get("darkness", false))
    var relic_visible := bool(context.get("relic_visible", false))
    var exit_visible := bool(context.get("exit_visible", false))

    if state == "flee":
        var escape_item := inventory.best_item_for("escape", health_ratio, perception.fear)
        return {"action": "use_item" if not escape_item.is_empty() else "flee", "item": escape_item}

    var healing_item := inventory.best_item_for("combat", health_ratio, perception.fear)
    if health_ratio <= 0.45 and healing_item == "potion":
        return {"action": "use_item", "item": "potion"}

    if locked_door and inventory.has("key"):
        return {"action": "use_item", "item": "key"}
    if darkness and inventory.has("torch"):
        return {"action": "use_item", "item": "torch"}

    match class_id:
        "scout":
            if nearby_threats > 0 and health_ratio > 0.35:
                return {"action": "fight", "style": "ranged"}
        "warrior":
            if nearby_threats > 0:
                return {"action": "fight", "style": "nearest"}
        "champion":
            if nearby_threats > 0:
                return {"action": "fight", "style": "dangerous"}
        "thief":
            if relic_visible and nearby_threats <= 1:
                return {"action": "collect_relic"}
            if exit_visible and state == "cautious":
                return {"action": "flee"}
        "mage":
            if nearby_threats >= 2 and inventory.has("bomb"):
                return {"action": "use_item", "item": "bomb"}
        "priest":
            if perception.morale <= 55.0:
                return {"action": "rally"}
        "berserker":
            if nearby_threats > 0:
                return {"action": "fight"}

    if state == "cautious":
        return {"action": "advance_carefully"}
    if relic_visible:
        return {"action": "collect_relic"}
    return {"action": "advance"}
