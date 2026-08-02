extends SceneTree

func _init() -> void:
    var catalog := AdventurerAbilityCatalog.new()
    var runtime := AbilityRuntime.new()
    if catalog.get_profiles().size() != 6:
        quit(1)
        return
    var thief := catalog.get_ability("thief")
    var result := runtime.use("thief-1", thief)
    if not result.success or result.effect != "disable_trap":
        quit(1)
        return
    if runtime.can_use("thief-1", thief):
        quit(1)
        return
    runtime.tick(4.0)
    if not runtime.can_use("thief-1", thief):
        quit(1)
        return
    var mage := catalog.get_ability("mage")
    if mage.effect != "damage_obstacle" or float(mage.range) < 5.0:
        quit(1)
        return
    print("Adventurer ability test passed")
    quit(0)
