extends SceneTree

func _init() -> void:
    var chest := TreasureChestState.new()
    var resolver := RunObjectiveResolver.new()

    if chest.begin_steal("thief"):
        quit(1)
        return
    chest.unlock()
    if not chest.begin_steal("thief"):
        quit(1)
        return
    if chest.tick_channel(1.0):
        quit(1)
        return
    if not is_equal_approx(chest.progress_ratio(), 1.0 / 3.0):
        quit(1)
        return
    chest.tick_channel(1.0, true)
    if chest.state != TreasureChestState.State.OPEN:
        quit(1)
        return
    chest.begin_steal("thief")
    if not chest.tick_channel(3.0):
        quit(1)
        return
    if resolver.resolve(chest, true, 1, 1) != RunObjectiveResolver.Outcome.DUNGEON_DEFEAT:
        quit(1)
        return
    chest.recover()
    if resolver.resolve(chest, false, 0, 2) != RunObjectiveResolver.Outcome.DUNGEON_VICTORY:
        quit(1)
        return
    if resolver.resolve(chest, false, 2, 0) != RunObjectiveResolver.Outcome.DUNGEON_VICTORY:
        quit(1)
        return

    print("Treasure objective test passed")
    quit(0)
