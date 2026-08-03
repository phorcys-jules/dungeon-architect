class_name ReactiveAudioDirector
extends RefCounted

const LAYERS := [&"base", &"tension", &"boss", &"victory", &"defeat"]
var biome: StringName = &"crypt"
var faction: StringName = &"sun_order"
var weights: Dictionary = {&"base": 1.0, &"tension": 0.0, &"boss": 0.0, &"victory": 0.0, &"defeat": 0.0}
var music_volume := 1.0
var muted := false
var reduced_sensory := false
var transition_log: Array[Dictionary] = []

func configure(biome_id: StringName, faction_id: StringName, settings: Dictionary) -> void:
    biome = biome_id
    faction = faction_id
    music_volume = clampf(float(settings.get("music", 1.0)), 0.0, 1.0)
    muted = bool(settings.get("muted", false))
    reduced_sensory = bool(settings.get("reduced_sensory", false))

func update(danger: float, boss_ratio: float, result := "") -> Dictionary:
    var target := {&"base": 1.0, &"tension": clampf(danger, 0.0, 1.0), &"boss": clampf(1.0 - boss_ratio, 0.0, 1.0) if boss_ratio >= 0.0 else 0.0, &"victory": 1.0 if result == "victory" else 0.0, &"defeat": 1.0 if result == "defeat" else 0.0}
    if reduced_sensory:
        target.tension = minf(float(target.tension), 0.45)
        target.boss = minf(float(target.boss), 0.55)
    for layer in LAYERS:
        weights[layer] = 0.0 if muted else lerpf(float(weights.get(layer, 0.0)), float(target[layer]) * music_volume, 0.35)
    var snapshot := {"biome": biome, "faction": faction, "weights": weights.duplicate(true), "transition_seconds": 0.4}
    transition_log.append(snapshot.duplicate(true))
    if transition_log.size() > 32:
        transition_log.pop_front()
    return snapshot

func stinger(event: StringName) -> Dictionary:
    var allowed := [&"combo", &"capture", &"mutation", &"rival", &"sabotage"]
    return {"play": not muted and allowed.has(event), "event": event, "priority": allowed.find(event)}

func should_load_audio(headless: bool) -> bool:
    return not headless and not muted and music_volume > 0.0
