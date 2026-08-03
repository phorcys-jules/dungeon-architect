class_name V06RunIntegration
extends RefCounted

var store := V06ProgressionStore.new()
var events := RunEventDirector.new()
var challenges := RunChallengeTracker.new()
var synergies := SynergyRuntime.new()
var encyclopedia := EncyclopediaProgress.new()
var global_stats := GlobalRunStats.new()
var achievements := AchievementTracker.new()
var run_seed := 0
var run_tags: Array[String] = []

func _init(state_store: V06ProgressionStore = null) -> void:
    if state_store != null:
        store = state_store

func begin_run(seed_value: int, tags: Array[String]) -> void:
    run_seed = seed_value
    run_tags = tags.duplicate()
    _restore(store.load_state())
    events.active_events.clear()
    var picked := RunChallengeCatalog.new().pick(run_seed, 3)
    var challenge_ids: Array[String] = []
    for definition in picked:
        challenge_ids.append(String(definition.id))
    challenges.start(challenge_ids)
    challenges.set_metric("traps_placed", 0)
    challenges.set_metric("direct_damage", 0)
    challenges.set_metric("captures", 0)
    challenges.set_metric("monster_families", 1)
    challenges.set_metric("resources_lost", 0)
    challenges.set_metric("walls_placed", 0)
    challenges.set_metric("monsters_lost", 0)
    synergies.evaluate(run_tags)
    _discover_run_content()

func start_wave(wave: int, biome_id: String) -> Dictionary:
    events.tick_stage()
    var event := events.roll(run_seed, wave, biome_id)
    return events.announcement(event)

func record_trap_placed() -> void:
    challenges.increment("traps_placed")

func record_wall_placed() -> void:
    challenges.increment("walls_placed")

func record_capture() -> void:
    challenges.increment("captures")

func adventurer_health_multiplier() -> float:
    return float(events.combined_effects().get("adventurer_health_multiplier", 1.0))

func adventurer_speed_multiplier() -> float:
    return float(events.combined_effects().get("adventurer_speed_multiplier", 1.0))

func event_multiplier(key: String, fallback: float = 1.0) -> float:
    return float(events.combined_effects().get(key, fallback))

func synergy_bonus(key: String, fallback: float = 0.0) -> float:
    return float(synergies.combined_effects().get(key, fallback))

func apply_choice_tags(tags: Array) -> void:
    for tag: Variant in tags:
        var run_tag := "room:%s" % String(tag)
        if not run_tags.has(run_tag):
            run_tags.append(run_tag)
    synergies.evaluate(run_tags)
    _discover_run_content()

func hud_snapshot() -> Dictionary:
    var challenge_labels: Array[String] = []
    for challenge_id in challenges.active:
        var progress := challenges.progress(challenge_id)
        var definition := challenges.catalog.get_definition(challenge_id)
        var reward: Dictionary = definition.get("reward", {})
        challenge_labels.append("%s %d/%d%s · +%d/+%d" % [String(progress.get("name", challenge_id)), roundi(float(progress.current)), roundi(float(progress.target)), " ✓" if bool(progress.get("completed", false)) else "", int(reward.get("gold", 0)), int(reward.get("essence", 0))])
    var event_labels: Array[String] = []
    var effect_entries: Array[Dictionary] = []
    for event in events.active_events:
        event_labels.append(String(event.name))
        effect_entries.append({
            "kind": "event",
            "name": String(event.name),
            "description": "%s\nDurée restante : %d vague(s)." % [String(event.description), int(event.remaining)],
        })
    var synergy_labels: Array[String] = []
    for synergy in synergies.presentation():
        synergy_labels.append(String(synergy.name))
        effect_entries.append({"kind": "synergy", "name": String(synergy.name), "description": String(synergy.description)})
    var near_synergies: Array[String] = []
    for synergy in synergies.catalog.all():
        if synergies.active.any(func(active_entry: Dictionary): return String(active_entry.id) == String(synergy.id)):
            continue
        var missing: Array[String] = []
        for required_tag in synergy.requires:
            if not run_tags.has(String(required_tag)):
                missing.append(String(required_tag))
        if missing.size() == 1:
            var hint := "%s — manque %s" % [String(synergy.name), missing[0].replace(":", " : ")]
            near_synergies.append(hint)
            effect_entries.append({"kind": "synergy_hint", "name": "Presque : %s" % String(synergy.name), "description": "Condition manquante : %s" % missing[0]})
    return {
        "challenges": challenge_labels,
        "events": event_labels,
        "synergies": synergy_labels,
        "modifiers": events.combined_effects(),
        "effect_entries": effect_entries,
        "near_synergies": near_synergies,
        "event_history": events.history.duplicate(),
    }

func finish_run(result: Dictionary) -> Dictionary:
    challenges.set_metric("captures", float(result.get("captures", 0)))
    var challenge_rewards := {"gold": 0, "essence": 0}
    var completed_ids: Array[String] = []
    for challenge_id in challenges.completed:
        completed_ids.append(challenge_id)
        var reward := challenges.claim(challenge_id)
        if bool(reward.get("ok", false)):
            challenge_rewards.gold += int(reward.gold)
            challenge_rewards.essence += int(reward.essence)

    var enriched := result.duplicate(true)
    enriched["synergy_ids"] = synergies.discovered.duplicate()
    enriched["challenge_progress"] = completed_ids
    var resources: Dictionary = enriched.get("resources", {}).duplicate(true)
    resources["gold"] = int(resources.get("gold", 0)) + int(challenge_rewards.gold)
    resources["essence"] = int(resources.get("essence", 0)) + int(challenge_rewards.essence)
    enriched["resources"] = resources
    global_stats.record_run(enriched)
    for tag in run_tags:
        var entry_id := _encyclopedia_id_for_tag(tag)
        if not entry_id.is_empty():
            encyclopedia.record_use(entry_id, bool(enriched.get("victory", false)))
    for synergy_id in synergies.discovered:
        encyclopedia.discover("synergy_%s" % synergy_id)
    for monster_id in enriched.get("monster_ids", []):
        encyclopedia.record_use("monster_%s" % String(monster_id), bool(enriched.get("victory", false)))
    for adventurer_id in enriched.get("adventurer_ids", []):
        encyclopedia.record_use("adventurer_%s" % String(adventurer_id), bool(enriched.get("victory", false)))
    for room_id in enriched.get("room_ids", []):
        encyclopedia.record_use("room_%s" % String(room_id), bool(enriched.get("victory", false)))
    encyclopedia.record_use("biome_%s" % String(enriched.get("biome", "crypt")), bool(enriched.get("victory", false)))
    achievements.add_progress("captures", int(enriched.get("captures", 0)))
    if bool(enriched.get("victory", false)) and int(enriched.get("resources_lost", 0)) == 0:
        achievements.add_progress("perfect_runs")
    _persist()
    return {
        "result": enriched,
        "challenge_rewards": challenge_rewards,
        "completed_challenges": completed_ids,
        "new_achievements": achievements.consume_notifications(),
    }

func _discover_run_content() -> void:
    for tag in run_tags:
        var entry_id := _encyclopedia_id_for_tag(tag)
        if not entry_id.is_empty():
            encyclopedia.discover(entry_id)
    for synergy in synergies.active:
        encyclopedia.discover("synergy_%s" % String(synergy.id))

func _encyclopedia_id_for_tag(tag: String) -> String:
    var parts := tag.split(":", false, 1)
    if parts.size() != 2 or not ["monster", "room", "biome", "adventurer"].has(parts[0]):
        return ""
    return "%s_%s" % [parts[0], parts[1]]

func _restore(state: Dictionary) -> void:
    events.from_dict(state.get("events", {}))
    synergies.from_dict(state.get("synergies", {}))
    encyclopedia.from_dict(state.get("encyclopedia", {}))
    global_stats.from_dict(state.get("global_stats", {}))
    achievements.from_dict(state.get("achievements", {}))

func _persist() -> bool:
    var state := store.load_state()
    state.merge({
        "events": events.to_dict(),
        "synergies": synergies.to_dict(),
        "encyclopedia": encyclopedia.to_dict(),
        "global_stats": global_stats.to_dict(),
        "achievements": achievements.to_dict(),
    }, true)
    return store.save_state(state)
