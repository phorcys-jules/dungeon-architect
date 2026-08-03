extends SceneTree

func _init() -> void:
    var stack := UndoStack.new()
    var state := {"tiles": {}} # map x,y -> tile id

    func do_place(x, y, tile_id):
        state.tiles["%d,%d" % [x,y]] = tile_id

    func do_remove(x, y):
        state.tiles.erase("%d,%d" % [x,y])

    # create action callables
    var a_do = Callable(self, "_action_place").bind(1,2,5)
    var a_undo = Callable(self, "_action_remove").bind(1,2)

    # fallback small helpers defined inline since GDScript top-level callables are awkward here
    func _action_place(x, y, tid):
        state.tiles["%d,%d" % [x,y]] = tid

    func _action_remove(x, y):
        state.tiles.erase("%d,%d" % [x,y])

    # perform place action via direct call and push undo
    _action_place(1,2,5)
    stack.push({"do": Callable(self, "_action_place").bind(1,2,5), "undo": Callable(self, "_action_remove").bind(1,2)})

    if state.tiles.has("1,2") and state.tiles["1,2"] == 5:
        # undo
        stack.undo()
        if state.tiles.has("1,2"):
            push_error("Undo failed: tile still present")
            quit(1)
        # redo
        stack.redo()
        if not (state.tiles.has("1,2") and state.tiles["1,2"] == 5):
            push_error("Redo failed: tile not restored")
            quit(1)
    else:
        push_error("Initial place failed")
        quit(1)
    print("Editor undo/redo test passed")
    quit(0)
