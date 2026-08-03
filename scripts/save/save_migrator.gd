class_name SaveMigrator
extends RefCounted

const CURRENT_VERSION := 5

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

    if version < 4:
        result["discoveries"] = result.get("discoveries", {})
        result["achievements"] = result.get("achievements", {})
        result["global_stats"] = result.get("global_stats", {})
        result["completed_challenges"] = result.get("completed_challenges", [])
        result["black_market"] = result.get("black_market", {})
        version = 4

    if version < 5:
        result["campaign_v08"] = result.get("campaign_v08", {})
        result["nemesis"] = result.get("nemesis", {})
        result["blueprints"] = result.get("blueprints", {})
        result["village_quests"] = result.get("village_quests", {})
        result["accessibility_v08"] = result.get("accessibility_v08", {})
        version = 5

    result["version"] = CURRENT_VERSION
    return result

func is_supported(payload: Dictionary) -> bool:
    var version := int(payload.get("version", 1))
    return version >= 1 and version <= CURRENT_VERSION
