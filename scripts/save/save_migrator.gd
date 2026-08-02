class_name SaveMigrator
extends RefCounted

const CURRENT_VERSION := 3

func migrate(payload: Dictionary) -> Dictionary:
    var result := payload.duplicate(true)
    var version := int(result.get("version", 1))

    if version < 2:
        result["resources"] = result.get("resources", {"gold": 0, "essence": 0, "stone": 0, "bones": 0})
        result["unlocks"] = result.get("unlocks", [])
        version = 2

    if version < 3:
        result["run_history"] = result.get("run_history", [])
        result["tutorial"] = result.get("tutorial", {"completed": []})
        result["feedback_settings"] = result.get("feedback_settings", GameFeedbackSettings.new().serialize())
        version = 3

    result["version"] = CURRENT_VERSION
    return result

func is_supported(payload: Dictionary) -> bool:
    var version := int(payload.get("version", 1))
    return version >= 1 and version <= CURRENT_VERSION
