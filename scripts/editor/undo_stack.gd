class_name UndoStack
extends RefCounted

# Simple undo/redo stack storing actions as dictionaries:
# {"do": Callable, "undo": Callable}

var _undo_stack: Array = []
var _redo_stack: Array = []

func push(action: Dictionary) -> void:
    # action must contain callables 'do' and 'undo'
    _undo_stack.append(action)
    _redo_stack.clear()

func can_undo() -> bool:
    return _undo_stack.size() > 0

func can_redo() -> bool:
    return _redo_stack.size() > 0

func undo() -> void:
    if not can_undo():
        return
    var action = _undo_stack.pop_back()
    if action.has("undo") and typeof(action.undo) == TYPE_CALLABLE:
        action.undo.call()
    _redo_stack.append(action)

func redo() -> void:
    if not can_redo():
        return
    var action = _redo_stack.pop_back()
    if action.has("do") and typeof(action.do) == TYPE_CALLABLE:
        action.do.call()
    _undo_stack.append(action)

func clear() -> void:
    _undo_stack.clear()
    _redo_stack.clear()
