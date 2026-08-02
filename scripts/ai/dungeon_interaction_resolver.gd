class_name DungeonInteractionResolver
extends RefCounted

enum Action { NONE, USE_KEY, PICK_LOCK, BREAK_DOOR, BYPASS, HEAL, PURIFY, INSPECT }

func resolve_door(profile_id: String, has_key: bool, can_bypass: bool = false) -> Action:
    if has_key:
        return Action.USE_KEY
    if can_bypass or profile_id == "mage":
        return Action.BYPASS
    if profile_id == "thief":
        return Action.PICK_LOCK
    if profile_id == "berserker":
        return Action.BREAK_DOOR
    return Action.NONE

func resolve_room(profile_id: String, room_tags: Array[String], health_ratio: float) -> Action:
    if room_tags.has("healing") and health_ratio < 0.65:
        return Action.HEAL
    if room_tags.has("cursed") and profile_id == "priest":
        return Action.PURIFY
    if room_tags.has("false_treasure"):
        return Action.INSPECT
    return Action.NONE

func consumes_key(action: Action) -> bool:
    return action == Action.USE_KEY

func changes_navigation(action: Action) -> bool:
    return action in [Action.USE_KEY, Action.PICK_LOCK, Action.BREAK_DOOR, Action.BYPASS]
