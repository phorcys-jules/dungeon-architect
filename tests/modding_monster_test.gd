extends SceneTree

func _init() -> void:
    var loader := ModLoader.new()
    loader.clear_registry()
    var mods := loader.load_mods_from_dir("mods")
    if mods.size() == 0:
        push_error("No mods loaded from mods/ - expected example_monster.json")
        quit(1)
        return
    var m := loader.get_registered_mod("example_slow_mimic")
    if not m or not m.has("data"):
        push_error("Registered mod missing data")
        quit(1)
        return
    var d := m.data
    if d.name != "Slow Mimic":
        push_error("Monster name mismatch")
        quit(1)
        return
    if float(d.base_speed) <= 0:
        push_error("Monster base_speed invalid")
        quit(1)
        return
    print("Modding monster test passed")
    quit(0)
