extends SceneTree

func _init() -> void:
	var loader := ModLoader.new()
	var mods := loader.load_mods_from_dir("mods")
	if mods.is_empty():
		push_error("No mods loaded from mods/ - expected example_trap.json")
		quit(1)
		return

	var example_mod: Dictionary = {}
	for mod in mods:
		if String(mod.get("id", "")) == "example_fire_trap":
			example_mod = mod
			break

	if example_mod.is_empty():
		push_error("example_fire_trap was not loaded")
		quit(1)
		return
	if not example_mod.has("type") or not example_mod.has("data"):
		push_error("Loaded example mod missing keys")
		quit(1)
		return
	if String(example_mod.type) != "trap":
		push_error("example mod should be trap type")
		quit(1)
		return

	print("Modding API test passed")
	quit(0)
