extends SceneTree

const ModLoader := preload("res://scripts/mod_loader.gd")

func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("mod_loader test failed: %s" % message)
	quit(1)
	return false

func _init() -> void:
	var loader := ModLoader.new()
	var valid_mod := {
		"id": "mod1",
		"type": "trap",
		"data": {
			"name": "Test Trap",
			"cost": 25,
			"damage": 10,
			"cooldown": 1.5,
		},
	}
	if not _check(loader.validate_mod_definition(valid_mod), "valid mod"):
		return
	var invalid_mod := {"id": "mod2", "data": {}}
	if not _check(not loader.validate_mod_definition(invalid_mod), "invalid mod detected"):
		return
	print("Mod loader test passed")
	quit(0)
