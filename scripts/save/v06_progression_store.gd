class_name V06ProgressionStore
extends RefCounted

const SAVE_VERSION := 1
const DEFAULT_PATH := "user://v06_progression.json"

var save_path := DEFAULT_PATH

func _init(path: String = DEFAULT_PATH) -> void:
    save_path = path

func load_state() -> Dictionary:
    if not FileAccess.file_exists(save_path):
        return {}
    var file := FileAccess.open(save_path, FileAccess.READ)
    if file == null:
        return {}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    var payload: Dictionary = parsed
    if int(payload.get("version", 0)) != SAVE_VERSION:
        return {}
    return Dictionary(payload.get("state", {})).duplicate(true)

func save_state(state: Dictionary) -> bool:
    var file := FileAccess.open(save_path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify({"version": SAVE_VERSION, "state": state}))
    file.close()
    return true

func delete_save() -> bool:
    if not FileAccess.file_exists(save_path):
        return true
    return DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path)) == OK
