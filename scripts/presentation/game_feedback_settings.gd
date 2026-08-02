class_name GameFeedbackSettings
extends RefCounted

var master_volume := 1.0
var music_volume := 0.8
var effects_volume := 1.0
var screen_shake_strength := 1.0
var particles_enabled := true
var reduced_motion := false

func apply(values: Dictionary) -> void:
    master_volume = clampf(float(values.get("master_volume", master_volume)), 0.0, 1.0)
    music_volume = clampf(float(values.get("music_volume", music_volume)), 0.0, 1.0)
    effects_volume = clampf(float(values.get("effects_volume", effects_volume)), 0.0, 1.0)
    screen_shake_strength = clampf(float(values.get("screen_shake_strength", screen_shake_strength)), 0.0, 1.0)
    particles_enabled = bool(values.get("particles_enabled", particles_enabled))
    reduced_motion = bool(values.get("reduced_motion", reduced_motion))

func serialize() -> Dictionary:
    return {
        "master_volume": master_volume,
        "music_volume": music_volume,
        "effects_volume": effects_volume,
        "screen_shake_strength": screen_shake_strength,
        "particles_enabled": particles_enabled,
        "reduced_motion": reduced_motion,
    }
