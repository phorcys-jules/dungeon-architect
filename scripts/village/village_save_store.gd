class_name VillageSaveStore
extends RefCounted

const SAVE_VERSION := 2
const DEFAULT_PATH := "user://village_save.json"

var save_path := DEFAULT_PATH

func _init(path: String = DEFAULT_PATH) -> void:
    save_path = path

func save_den(den: DenProgression) -> bool:
    if den == null:
        return false
    var payload := {
        "version": SAVE_VERSION,
        "den": den.serialize(),
    }
    var file := FileAccess.open(save_path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(payload))
    file.close()
    return true

func load_den() -> DenProgression:
    var den := DenProgression.new()
    if not FileAccess.file_exists(save_path):
        return den
    var file := FileAccess.open(save_path, FileAccess.READ)
    if file == null:
        return den
    var raw := file.get_as_text()
    file.close()
    var parsed: Variant = JSON.parse_string(raw)
    if typeof(parsed) != TYPE_DICTIONARY:
        return den
    var payload: Dictionary = parsed
    var version := int(payload.get("version", 0))
    if version < 1 or version > SAVE_VERSION:
        return den
    var den_data: Variant = payload.get("den", {})
    if typeof(den_data) == TYPE_DICTIONARY:
        den.restore(den_data)
    return den

func delete_save() -> bool:
    if not FileAccess.file_exists(save_path):
        return true
    return DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path)) == OK
