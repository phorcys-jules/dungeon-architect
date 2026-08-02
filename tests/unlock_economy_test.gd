extends SceneTree

func _init() -> void:
    var economy := UnlockEconomy.new()
    economy.add_resource("gold", 100)
    economy.add_resource("essence", 20)
    if not economy.purchase("ghost_upgrade", {"gold": 60, "essence": 10}):
        quit(1)
        return
    if economy.purchase("ghost_upgrade", {"gold": 1}):
        quit(1)
        return
    if int(economy.resources.gold) != 40 or int(economy.resources.essence) != 10:
        quit(1)
        return
    var restored := UnlockEconomy.new()
    restored.restore(economy.serialize())
    if not restored.is_unlocked("ghost_upgrade"):
        quit(1)
        return
    print("Unlock economy test passed")
    quit(0)
