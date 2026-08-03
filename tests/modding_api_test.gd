extends SceneTree

func _init() -> void:
    var loader := ModLoader.new()
    var mods := loader.load_mods_from_dir("mods")
    if mods.size() == 0:
        push_error("No mods loaded from mods/ - expected example_trap.json")
        quit(1)
        return
    var m := mods[0]
    if not m.has("id") or not m.has("type"):
        push_error("Loaded mod missing keys")
        quit(1)
        return
    if m.type != "trap":
        push_error("example mod should be trap type")
        quit(1)
        return
    print("Modding API test passed")
    quit(0)
