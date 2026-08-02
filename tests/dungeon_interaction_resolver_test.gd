extends SceneTree

func _init() -> void:
    var resolver := DungeonInteractionResolver.new()
    if resolver.resolve_door("thief", false) != DungeonInteractionResolver.Action.PICK_LOCK:
        quit(1)
        return
    if resolver.resolve_door("berserker", false) != DungeonInteractionResolver.Action.BREAK_DOOR:
        quit(1)
        return
    if resolver.resolve_door("priest", true) != DungeonInteractionResolver.Action.USE_KEY:
        quit(1)
        return
    if resolver.resolve_room("priest", ["cursed"], 1.0) != DungeonInteractionResolver.Action.PURIFY:
        quit(1)
        return
    if resolver.resolve_room("warrior", ["healing"], 0.4) != DungeonInteractionResolver.Action.HEAL:
        quit(1)
        return
    print("Dungeon interaction resolver test passed")
    quit(0)
