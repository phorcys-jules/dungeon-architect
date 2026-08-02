class_name RunRewardCalculator
extends RefCounted

const WAVE_VALUE := 12
const CAPTURE_VALUE := 18
const RELIC_VALUE := 6
const VICTORY_BONUS := 30

func calculate(waves_completed: int, captures: int, relics_protected: int, victory: bool) -> Dictionary:
    var safe_waves := maxi(waves_completed, 0)
    var safe_captures := maxi(captures, 0)
    var safe_relics := maxi(relics_protected, 0)
    var wave_reward := safe_waves * WAVE_VALUE
    var capture_reward := safe_captures * CAPTURE_VALUE
    var relic_reward := safe_relics * RELIC_VALUE
    var victory_reward := VICTORY_BONUS if victory else 0
    return {
        "waves_completed": safe_waves,
        "captures": safe_captures,
        "relics_protected": safe_relics,
        "wave_reward": wave_reward,
        "capture_reward": capture_reward,
        "relic_reward": relic_reward,
        "victory_reward": victory_reward,
        "total": wave_reward + capture_reward + relic_reward + victory_reward,
    }

func summary(reward: Dictionary) -> String:
    return "Vagues : %d (+%d)\nCaptures : %d (+%d)\nReliques protégées : %d (+%d)\nBonus victoire : +%d\nRessources permanentes : +%d" % [
        int(reward.get("waves_completed", 0)),
        int(reward.get("wave_reward", 0)),
        int(reward.get("captures", 0)),
        int(reward.get("capture_reward", 0)),
        int(reward.get("relics_protected", 0)),
        int(reward.get("relic_reward", 0)),
        int(reward.get("victory_reward", 0)),
        int(reward.get("total", 0)),
    ]
