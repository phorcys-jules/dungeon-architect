class_name FeedbackEventCatalog
extends RefCounted

const EVENTS := {
    "ui_confirm": {"sound": "ui_confirm", "animation": "pulse", "particles": false, "shake": 0.0},
    "trap_triggered": {"sound": "trap", "animation": "flash", "particles": true, "shake": 0.2},
    "monster_attack": {"sound": "monster_attack", "animation": "lunge", "particles": true, "shake": 0.25},
    "damage": {"sound": "hit", "animation": "damage_flash", "particles": true, "shake": 0.35},
    "critical": {"sound": "critical", "animation": "critical_pop", "particles": true, "shake": 0.7},
    "heal": {"sound": "heal", "animation": "heal_glow", "particles": true, "shake": 0.0},
    "treasure_stolen": {"sound": "alarm", "animation": "treasure_alert", "particles": true, "shake": 0.5},
}

func event(event_id: String, settings: GameFeedbackSettings) -> Dictionary:
    var result: Dictionary = EVENTS.get(event_id, {}).duplicate(true)
    if result.is_empty():
        return result
    result["particles"] = bool(result.particles) and settings.particles_enabled
    result["shake"] = 0.0 if settings.reduced_motion else float(result.shake) * settings.screen_shake_strength
    result["effects_volume"] = settings.effects_volume * settings.master_volume
    return result
