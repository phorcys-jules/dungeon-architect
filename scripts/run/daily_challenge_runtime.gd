class_name DailyChallengeRuntime
extends RefCounted

func seed_for(date_iso: String, version: String) -> int:
    return abs(("%s|%s" % [date_iso, version]).hash())

func definition(date_iso: String, version: String) -> Dictionary:
    var seed_value := seed_for(date_iso, version)
    var modifiers := ["fast_adventurers", "scarce_currency", "volatile_environment", "elite_patrol"]
    return {"date": date_iso, "version": version, "seed": seed_value, "modifier": modifiers[seed_value % modifiers.size()], "persistent_rewards": false}

func is_compatible(challenge: Dictionary, version: String) -> bool:
    return String(challenge.get("version", "")) == version and not bool(challenge.get("persistent_rewards", true))
