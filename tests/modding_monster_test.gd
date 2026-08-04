extends SceneTree

func _init() -> void:
	var loader := ModLoader.new()
	loader.clear_registry()
	var mods := loader.load_mods_from_dir("mods")
	if mods.is_empty():
		push_error("No mods loaded from mods/ - expected example_monster.json")
		quit(1)
		return

	var monster_mod: Dictionary = loader.get_registered_mod("example_slow_mimic")
	if monster_mod.is_empty() or not monster_mod.has("data"):
		push_error("Registered mod missing data")
		quit(1)
		return

	var data: Dictionary = monster_mod.data as Dictionary
	if String(data.get("name", "")) != "Slow Mimic":
		push_error("Monster name mismatch")
		quit(1)
		return
	if float(data.get("base_speed", 0.0)) <= 0.0:
		push_error("Monster base_speed invalid")
		quit(1)
		return

	print("Modding monster test passed")
	quit(0)
