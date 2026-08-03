extends SceneTree

const EditorValidator := preload("res://scripts/editor_validation.gd")

func _check(c,msg):
	if c: return true
	push_error("editor_validation test failed: %s" % msg)
	quit(1)
	return false

func _init() -> void:
	var m := {
		"width": 3, "height": 3,
		"tiles": {Vector2(0,0):true, Vector2(1,0):true, Vector2(2,0):true, Vector2(0,1):false, Vector2(1,1):true, Vector2(2,1):true, Vector2(0,2):true, Vector2(1,2):true, Vector2(2,2):true},
		"entrance": Vector2(0,0), "exit": Vector2(2,2)
	}
	var v := EditorValidator.new()
	if not _check(v.is_layout_solvable(m), "layout should be solvable"):
		return
	m.tiles[Vector2(1,1)] = false
	if not _check(v.is_layout_solvable(m), "layout still solvable around obstacle"):
		return
	m.tiles[Vector2(1,0)] = false
	m.tiles[Vector2(1,2)] = false
	if _check(not v.is_layout_solvable(m), "layout becomes unsolvable"):
		print("Editor validation test passed")
		quit(0)
