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
    var state := Dictionary(payload.get("state", {})).duplicate(true)
    var migrator := SaveMigrator.new()
    if not migrator.is_supported(state):
        return {}
    state = migrator.migrate(state)
    if not state.has("unlock_economy") and state.has("resources"):
        var migrated_unlocks := {}
        for unlock_id in state.get("unlocks", []):
            migrated_unlocks[String(unlock_id)] = true
        state["unlock_economy"] = {"resources": Dictionary(state.resources).duplicate(true), "unlocked": migrated_unlocks}
    if not state.has("tutorial_progress") and state.has("tutorial"):
        state["tutorial_progress"] = Dictionary(state.tutorial).duplicate(true)
    if not state.has("v08_campaign") and state.has("campaign_v08"):
        state["v08_campaign"] = Dictionary(state.campaign_v08).duplicate(true)
    return state

func save_state(state: Dictionary) -> bool:
    var file := FileAccess.open(save_path, FileAccess.WRITE)
    if file == null:
        return false
    var versioned_state := state.duplicate(true)
    versioned_state["version"] = GameVersion.SAVE_VERSION
    file.store_string(JSON.stringify({"version": SAVE_VERSION, "state": versioned_state}))
    file.close()
    return true

func delete_save() -> bool:
    if not FileAccess.file_exists(save_path):
        return true
    return DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path)) == OK
