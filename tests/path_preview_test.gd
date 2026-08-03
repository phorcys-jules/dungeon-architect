extends SceneTree

const PathPreview := preload("res://scripts/path_preview.gd")

func _check(c,msg):
	if c: return true
	push_error("path_preview test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var p := PathPreview.new()
	var map := {"expected_costs": {Vector2(0,0):1.0, Vector2(1,0):2.0}}
	var preview := p.preview_path(Vector2(0,0), Vector2(1,0), map)
	if not _check(preview.has(Vector2(0,0)), "preview contains start"):
		return
	if not _check(preview[Vector2(1,0)] == 2.0, "preview cost match"):
		return
	print("Path preview test passed")
	quit(0)
