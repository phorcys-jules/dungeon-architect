extends "res://scripts/dungeon_invasion_controller.gd"
class_name GameController

const RunEndControllerScript := preload("res://scripts/core/run_end_controller.gd")

var run_end: RunEndController = RunEndControllerScript.new()
var village_button: Button
var restart_button: Button
var current_run_id := ""
var captures_this_run := 0
var relics_protected_this_run := 0
var v06_integration := V06RunIntegration.new()
var objectives_label: Label
var modifiers_label: Label
var village_progression := V04ProgressionService.new()
var black_market := VillageBlackMarket.new()
var village_modifiers: Dictionary = {}

func _ready() -> void:
    super._ready()
    run_end.go_to_village.connect(_open_village)
    run_end.restart_run.connect(_restart_from_results)
    _build_run_end_actions()

func _build_interface() -> void:
    super._build_interface()
    objectives_label = Label.new()
    objectives_label.position = Vector2(772, 110)
    objectives_label.size = Vector2(152, 130)
    objectives_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    objectives_label.add_theme_font_size_override("font_size", 12)
    add_child(objectives_label)
    modifiers_label = Label.new()
    modifiers_label.position = Vector2(772, 252)
    modifiers_label.size = Vector2(152, 178)
    modifiers_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    modifiers_label.add_theme_font_size_override("font_size", 12)
    add_child(modifiers_label)

func _build_run_end_actions() -> void:
    village_button = Button.new()
    village_button.text = "Village"
    village_button.position = Vector2(32, 414)
    village_button.size = Vector2(228, 38)
    _style_action_button(village_button, Color("526d82"))
    village_button.visible = false
    village_button.pressed.connect(run_end.request_village)
    result_panel.add_child(village_button)

    restart_button = Button.new()
    restart_button.text = "Nouvelle run"
    restart_button.position = Vector2(280, 414)
    restart_button.size = Vector2(228, 38)
    _style_action_button(restart_button, Color("7a526d"))
    restart_button.visible = false
    restart_button.pressed.connect(run_end.request_restart)
    result_panel.add_child(restart_button)

func _begin_tracked_run() -> void:
    current_run_id = "%d-%d" % [Time.get_unix_time_from_system(), Time.get_ticks_msec()]
    captures_this_run = 0
    relics_protected_this_run = 0
    run_end.begin_run(current_run_id)
    _load_village_progression()
    var forge_level := int(village_progression.state.buildings.get("forge", 0))
    set_unlocked_traps(TrapCatalogScript.unlocked_for_forge_level(forge_level))
    var tags := get_run_tags()
    for building_id in village_progression.state.buildings:
        if int(village_progression.state.buildings[building_id]) > 0:
            tags.append("building:%s" % String(building_id))
    for purchase_id in black_market.purchased_ids:
        tags.append("market:%s" % purchase_id)
    tags.append("role:guardian")
    v06_integration.begin_run(int(current_run_id.hash()), tags)
    _set_run_end_actions_visible(false)

func _prepare_current_wave() -> void:
    var announcement := v06_integration.start_wave(waves.current_wave, active_biome.active_biome_id)
    super._prepare_current_wave()
    adventurer_health.max_health = maxi(1, roundi(float(waves.get_adventurer_health()) * v06_integration.adventurer_health_multiplier()))
    adventurer_health.reset()
    if not announcement.is_empty():
        status_label.text += "\nÉvénement : %s — %s" % [String(announcement.title), String(announcement.body)]
    _refresh_v06_hud()

func _on_adventurer_died() -> void:
    var was_invasion := game_state == GameState.INVASION
    super._on_adventurer_died()
    if was_invasion:
        captures_this_run += 1
        v06_integration.record_capture()

func _finish_campaign(victory: bool, message: String) -> void:
    if game_state == GameState.CAMPAIGN_FINISHED:
        return
    relics_protected_this_run = collectible_route.get_remaining_count()
    super._finish_campaign(victory, message)
    var completed_waves := waves.current_wave if victory else maxi(waves.current_wave - 1, 0)
    var reward := run_end.finish(completed_waves, captures_this_run, relics_protected_this_run, victory)
    result_summary.text += "\n\n" + run_end.reward_service.calculator.summary(reward)
    var meta := v06_integration.finish_run({
        "victory": victory,
        "wave": waves.current_wave,
        "score": run_stats.total_damage + completed_waves * 100,
        "duration_seconds": roundi(run_stats.elapsed_time),
        "captures": captures_this_run,
        "resources": {"gold": int(reward.get("total", 0))},
        "monster_ids": get_monster_ids(),
        "adventurer_ids": _encountered_adventurer_ids(),
        "room_ids": _placed_room_ids(),
        "biome": active_biome.active_biome_id,
        "resources_lost": 0 if victory else 1,
    })
    var challenge_rewards: Dictionary = meta.challenge_rewards
    result_summary.text += "\nDéfis : +%d or, +%d essence" % [int(challenge_rewards.gold), int(challenge_rewards.essence)]
    if not meta.completed_challenges.is_empty():
        result_summary.text += "\nDéfis réussis : %s" % ", ".join(meta.completed_challenges)
    if not meta.new_achievements.is_empty():
        result_summary.text += "\nSuccès : %s" % ", ".join(meta.new_achievements)
    _set_run_end_actions_visible(true)

func _start_new_campaign() -> void:
    _begin_tracked_run()
    super._start_new_campaign()

func _current_adventurer_speed_multiplier() -> float:
    return super._current_adventurer_speed_multiplier() * v06_integration.adventurer_speed_multiplier() * active_biome.rule_value("movement_speed_multiplier", 1.0)

func _configure_trap(trap: SpikeTrap) -> void:
    trap.damage = roundi(trap.damage * (1.0 + float(village_modifiers.get("trap_damage_multiplier", 0.0))) * active_biome.rule_value("trap_damage_multiplier", 1.0))

func _configure_defender(defender: Defender) -> void:
    defender.cooldown = maxf(0.2, defender.cooldown / (1.0 + float(village_modifiers.get("effect_duration_multiplier", 0.0))))

func _load_village_progression() -> void:
    var state := v06_integration.store.load_state()
    village_progression = V04ProgressionService.new(state.get("v04_progression", {}))
    black_market.from_dict(state.get("black_market", {}))
    village_modifiers = village_progression.combined_modifiers()

func _on_trap_placed() -> void:
    v06_integration.record_trap_placed()
    _refresh_v06_hud()

func record_v06_wall_placed() -> void:
    v06_integration.record_wall_placed()
    _refresh_v06_hud()

func _refresh_v06_hud() -> void:
    if not objectives_label or not modifiers_label:
        return
    var snapshot := v06_integration.hud_snapshot()
    objectives_label.text = "OBJECTIFS\n%s" % ("\n".join(snapshot.challenges) if not snapshot.challenges.is_empty() else "Aucun")
    var active_lines: Array[String] = []
    active_lines.append_array(snapshot.events)
    active_lines.append_array(snapshot.synergies)
    modifiers_label.text = "EFFETS ACTIFS\n%s" % ("\n".join(active_lines) if not active_lines.is_empty() else "Aucun")

func _set_run_end_actions_visible(value: bool) -> void:
    if village_button:
        village_button.visible = value
    if restart_button:
        restart_button.visible = value

func _open_village() -> void:
    get_tree().change_scene_to_file("res://scenes/village_screen.tscn")

func _restart_from_results() -> void:
    _start_new_campaign()

func _encountered_adventurer_ids() -> Array[String]:
    var ids: Array[String] = []
    for wave_number in range(1, waves.current_wave + 1):
        var data: WaveData = WaveManager.WAVE_RESOURCES[wave_number - 1]
        if data.adventurer != null and not ids.has(data.adventurer.id):
            ids.append(data.adventurer.id)
    return ids

func _placed_room_ids() -> Array[String]:
    var ids: Array[String] = []
    for room: RoomData in placed_rooms.values():
        ids.append(room.room_id)
    return ids
