extends SceneTree

const ModLoader := preload("res://scripts/mod_loader.gd")

func _check(c,msg):
	if c: return true
	push_error("mod_loader test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var m := ModLoader.new()
	var good := {"id":"mod1","type":"trap","data":{"damage":10}}
	if not _check(m.validate_mod_definition(good), "valid mod"):
		return
	var bad := {"id":"mod2","data":{}}
	if not _check(not m.validate_mod_definition(bad), "invalid mod detected"):
		return
	print("Mod loader test passed")
	quit(0)
