extends SceneTree

const MonsterOrders := preload("res://scripts/monster_orders.gd")

func _check(c,msg):
	if c: return true
	push_error("monster_orders test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var m := MonsterOrders.new()
	var brave := {"bravery":0.8}
	var cow := {"bravery":0.1}
	if not _check(m.resolve_order(brave, "guard", {}).accepted, "guard accepted"):
		return
	if not _check(m.resolve_order(cow, "retreat", {}).accepted, "coward retreat"):
		return
	print("Monster orders test passed")
	quit(0)
