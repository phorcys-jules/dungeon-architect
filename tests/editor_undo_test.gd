extends SceneTree

var state := {"tiles": {}}

func _action_place(x: int, y: int, tile_id: int) -> void:
    state.tiles["%d,%d" % [x, y]] = tile_id

func _action_remove(x: int, y: int) -> void:
    state.tiles.erase("%d,%d" % [x, y])

func _init() -> void:
    var stack := UndoStack.new()
    var place_action := Callable(self, "_action_place").bind(1, 2, 5)
    var remove_action := Callable(self, "_action_remove").bind(1, 2)

    place_action.call()
    stack.push({"do": place_action, "undo": remove_action})

    if not (state.tiles.has("1,2") and state.tiles["1,2"] == 5):
        push_error("Initial place failed")
        quit(1)
        return

    stack.undo()
    if state.tiles.has("1,2"):
        push_error("Undo failed: tile still present")
        quit(1)
        return

    stack.redo()
    if not (state.tiles.has("1,2") and state.tiles["1,2"] == 5):
        push_error("Redo failed: tile not restored")
        quit(1)
        return

    print("Editor undo/redo test passed")
    quit(0)
