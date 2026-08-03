extends SceneTree

const AIDirector := preload("res://scripts/ai_director.gd")

func _check(c,msg):
	if c: return true
	push_error("ai_director test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var d := AIDirector.new()
	# simulate strong performance (high win rates)
	for i in range(5):
		d.record_summary({"total":10, "victories":8})
	var adj1 := d.compute_adjustment()
	if not _check(adj1.spawn_rate > 1.0, "spawn rate should increase when win rate > target"):
		return
	# simulate poor performance (low win rates)
	d.reset()
	for i in range(5):
		d.record_summary({"total":10, "victories":1})
	var adj2 := d.compute_adjustment()
	if not _check(adj2.spawn_rate < 1.0, "spawn rate should decrease when win rate < target"):
		return
	print("AIDirector prototype test passed")
	quit(0)
