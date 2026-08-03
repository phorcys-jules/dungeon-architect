extends "res://scripts/dungeon_invasion_controller.gd"
class_name GameController

const RunEndControllerScript := preload("res://scripts/core/run_end_controller.gd")
const AdventurerIntelligenceScript := preload("res://scripts/meta/adventurer_intelligence.gd")
const RetroSfxPlayerScript := preload("res://scripts/presentation/retro_sfx_player.gd")
const ComboRuntimeScript := preload("res://scripts/combat/combo_runtime.gd")
const DefenseEvolutionScript := preload("res://scripts/core/defense_evolution.gd")
const TacticalPowerRuntimeScript := preload("res://scripts/run/tactical_power_runtime.gd")
const AdventurerSquadRuntimeScript := preload("res://scripts/run/adventurer_squad_runtime.gd")
const TacticalHeatmapScript := preload("res://scripts/run/tactical_heatmap.gd")
const RoomRuleRuntimeScript := preload("res://scripts/run/room_rule_runtime.gd")
const ContextualTutorialScript := preload("res://scripts/tutorial/contextual_tutorial.gd")

var run_end: RunEndController = RunEndControllerScript.new()
var village_button: Button
var restart_button: Button
var current_run_id := ""
var captures_this_run := 0
var relics_protected_this_run := 0
var v06_integration := V06RunIntegration.new()
var objectives_label: Label
var modifiers_label: Label
var modifiers_scroll: ScrollContainer
var modifiers_list: VBoxContainer
var effect_rows: Array[Button] = []
var event_banner: Label
var history_button: Button
var village_progression := V04ProgressionService.new()
var black_market := VillageBlackMarket.new()
var village_modifiers: Dictionary = {}
var village_den_store := VillageSaveStore.new()
var village_den := DenProgression.new()
var monster_roster := MonsterRoster.new()
var monster_progression := MonsterProgression.new()
var labyrinth_modules := LabyrinthModuleLoadout.new()
var room_deck_selection := RoomDeckSelection.new()
var adventurer_intelligence: RefCounted = AdventurerIntelligenceScript.new()
var intelligence_label: Label
var choice_engine := RogueliteChoiceEngine.new()
var choice_buttons: Array[Button] = []
var current_choice_offer: Array[Dictionary] = []
var selected_choice_ids: Array[StringName] = []
var run_choice_modifiers: Dictionary = {}
var feedback_settings := GameFeedbackSettings.new()
var sfx_player: Node
var combo_runtime = ComboRuntimeScript.new()
var combo_zone_cell := Vector2i(-1, -1)
var defense_evolution = DefenseEvolutionScript.new()
var inspected_defense_cell := Vector2i(-1, -1)
var defense_inspector: PanelContainer
var defense_inspector_text: Label
var tactical_powers = TacticalPowerRuntimeScript.new()
var tactical_energy_label: Label
var tactical_power_buttons: Dictionary = {}
var emergency_lock_time := 0.0
var hunt_order_time := 0.0
var hunt_original_behaviours: Array[PacmanLoopRules.Behaviour] = []
var pending_run_choice := false
var adventurer_squad = AdventurerSquadRuntimeScript.new()
var tactical_heatmap = TacticalHeatmapScript.new()
var room_rules = RoomRuleRuntimeScript.new()
var contextual_tutorial = ContextualTutorialScript.new()
var heatmap_visible := false
var heatmap_button: Button

func _ready() -> void:
    village_den = village_den_store.load_den()
    _load_village_progression()
    set_monster_team(monster_roster.selected_team)
    set_biome(room_deck_selection.biome_id)
    set_room_deck(room_deck_selection.selected)
    super._ready()
    run_end.go_to_village.connect(_open_village)
    run_end.restart_run.connect(_restart_from_results)
    _build_run_end_actions()

func _build_interface() -> void:
    super._build_interface()
    sfx_player = RetroSfxPlayerScript.new()
    sfx_player.name = "RetroSfxPlayer"
    add_child(sfx_player)
    intelligence_label = Label.new()
    intelligence_label.position = Vector2(772, 104)
    intelligence_label.size = Vector2(152, 98)
    intelligence_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    intelligence_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    intelligence_label.add_theme_font_size_override("font_size", 9)
    intelligence_label.add_theme_color_override("font_color", Color("b8d8ff"))
    add_child(intelligence_label)
    objectives_label = Label.new()
    objectives_label.position = Vector2(772, 206)
    objectives_label.size = Vector2(152, 92)
    objectives_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    objectives_label.add_theme_font_size_override("font_size", 9)
    add_child(objectives_label)
    modifiers_label = Label.new()
    modifiers_label.position = Vector2(772, 302)
    modifiers_label.size = Vector2(152, 20)
    modifiers_label.text = "EFFETS ACTIFS"
    modifiers_label.add_theme_font_size_override("font_size", 12)
    add_child(modifiers_label)
    modifiers_scroll = ScrollContainer.new()
    modifiers_scroll.position = Vector2(768, 324)
    modifiers_scroll.size = Vector2(160, 102)
    modifiers_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    add_child(modifiers_scroll)
    modifiers_list = VBoxContainer.new()
    modifiers_list.custom_minimum_size = Vector2(156, 0)
    modifiers_list.add_theme_constant_override("separation", 2)
    modifiers_scroll.add_child(modifiers_list)
    history_button = Button.new()
    history_button.name = "EventHistoryButton"
    history_button.position = Vector2(768, 430)
    history_button.size = Vector2(160, 24)
    history_button.text = "HISTORIQUE (0)"
    history_button.add_theme_font_size_override("font_size", 10)
    history_button.pressed.connect(_show_event_history)
    add_child(history_button)
    event_banner = Label.new()
    event_banner.name = "EventBanner"
    event_banner.position = Vector2(205, 108)
    event_banner.size = Vector2(530, 42)
    event_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    event_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    event_banner.add_theme_font_size_override("font_size", 15)
    event_banner.add_theme_color_override("font_color", Color("ffe08a"))
    event_banner.visible = false
    add_child(event_banner)
    _build_defense_inspector()
    _build_tactical_power_ui()
    heatmap_button = Button.new()
    heatmap_button.position = Vector2(772, 568)
    heatmap_button.size = Vector2(152, 26)
    heatmap_button.text = "[H] Carte tactique"
    heatmap_button.tooltip_text = "Affiche la circulation de la vague précédente."
    heatmap_button.pressed.connect(_toggle_heatmap)
    add_child(heatmap_button)
    for index in 3:
        var choice_button := Button.new()
        choice_button.position = Vector2(32 + index * 160, 326)
        choice_button.size = Vector2(148, 64)
        choice_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        choice_button.visible = false
        choice_button.pressed.connect(_select_run_choice.bind(index))
        _style_action_button(choice_button, Color("725b9a"))
        result_panel.add_child(choice_button)
        choice_buttons.append(choice_button)

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
    selected_choice_ids.clear()
    run_choice_modifiers.clear()
    current_choice_offer.clear()
    pending_run_choice = false
    tactical_powers.reset()
    emergency_lock_time = 0.0
    hunt_order_time = 0.0
    loop_rules.door_cooldown = 2.0
    _set_choice_buttons_visible(false)
    run_end.begin_run(current_run_id)
    village_den = village_den_store.load_den()
    _load_village_progression()
    set_monster_team(monster_roster.selected_team)
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
    combo_runtime.clear()
    combo_zone_cell = Vector2i(-1, -1)
    _set_choice_buttons_visible(false)
    result_summary.size.y = 318
    var announcement := v06_integration.start_wave(waves.current_wave, active_biome.active_biome_id)
    super._prepare_current_wave()
    adventurer_squad.configure(waves.current_wave)
    tactical_heatmap.finish_wave()
    _configure_room_rules()
    var hint := contextual_tutorial.next_hint(&"start_wave")
    if not hint.is_empty():
        status_label.tooltip_text = "%s\nCodex : %s" % [String(hint.text), String(hint.codex)]
    _refresh_adventurer_intelligence()
    var village_health := 1.0 + float(village_modifiers.get("adventurer_health_multiplier", 0.0))
    adventurer_health.max_health = maxi(1, roundi(float(waves.get_adventurer_health()) * v06_integration.adventurer_health_multiplier() * village_health))
    adventurer_health.reset()
    if not announcement.is_empty():
        status_label.text += "\nÉvénement : %s — %s" % [String(announcement.title), String(announcement.body)]
        _announce_event(announcement)
    _refresh_active_gameplay_modifiers()
    _refresh_v06_hud()

func _on_adventurer_died() -> void:
    var was_invasion := game_state == GameState.INVASION
    super._on_adventurer_died()
    if was_invasion:
        captures_this_run += 1
        v06_integration.record_capture()
        if game_state == GameState.WAVE_RESULT:
            _offer_run_choices()

func _on_primary_button_pressed() -> void:
    if game_state == GameState.WAVE_RESULT and pending_run_choice:
        status_label.text = "Choisissez une amélioration avant de préparer la prochaine vague."
        return
    super._on_primary_button_pressed()

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
        "loot": loot_ledger.snapshot(),
        "monster_ids": get_monster_ids(),
        "adventurer_ids": _encountered_adventurer_ids(),
        "room_ids": _placed_room_ids(),
        "biome": active_biome.active_biome_id,
        "resources_lost": 0 if victory else 1,
        "combo_counts": combo_runtime.trigger_counts.duplicate(true),
        "tactical_heatmap": tactical_heatmap.snapshot(),
        "room_rule_stats": room_rules.stats(),
        "squad_roles": adventurer_squad.members.map(func(member): return String(member.role)),
    })
    var challenge_rewards: Dictionary = meta.challenge_rewards
    result_summary.text += "\nDéfis : +%d or, +%d essence" % [int(challenge_rewards.gold), int(challenge_rewards.essence)]
    if not meta.completed_challenges.is_empty():
        result_summary.text += "\nDéfis réussis : %s" % ", ".join(meta.completed_challenges)
    if not meta.new_achievements.is_empty():
        result_summary.text += "\nSuccès : %s" % ", ".join(meta.new_achievements)
    var experience_gain := maxi(completed_waves * 6 + captures_this_run * 12, 6)
    for archetype in active_monster_archetypes:
        monster_progression.grant_experience(archetype.archetype_id, experience_gain)
    var persisted_state := v06_integration.store.load_state()
    persisted_state["monster_roster"] = monster_roster.to_dict()
    persisted_state["monster_progression"] = monster_progression.to_dict()
    persisted_state["labyrinth_modules"] = labyrinth_modules.to_dict()
    persisted_state["room_deck_selection"] = room_deck_selection.to_dict()
    persisted_state["adventurer_intelligence"] = adventurer_intelligence.to_dict()
    persisted_state["contextual_tutorial"] = contextual_tutorial.serialize()
    v06_integration.store.save_state(persisted_state)
    result_summary.text += "\nÉquipe de monstres : +%d XP" % experience_gain
    _set_run_end_actions_visible(true)

func _start_new_campaign() -> void:
    _begin_tracked_run()
    super._start_new_campaign()

func _current_adventurer_speed_multiplier() -> float:
    var market_speed := 1.0 + float(village_modifiers.get("adventurer_speed_multiplier", 0.0))
    return super._current_adventurer_speed_multiplier() * v06_integration.adventurer_speed_multiplier() * active_biome.rule_value("movement_speed_multiplier", 1.0) * market_speed

func _configure_trap(trap: SpikeTrap) -> void:
    var run_bonus := float(run_choice_modifiers.get("trap_damage_multiplier", 0.0))
    trap.damage = roundi(trap.damage * (1.0 + float(village_modifiers.get("trap_damage_multiplier", 0.0)) + run_bonus) * active_biome.rule_value("trap_damage_multiplier", 1.0))
    trap.effect_duration *= _effect_duration_multiplier()
    trap.cooldown_duration *= v06_integration.event_multiplier("trap_cooldown_multiplier")

func _configure_defender(defender: Defender) -> void:
    defender.cooldown = maxf(0.2, defender.cooldown / (1.0 + float(village_modifiers.get("effect_duration_multiplier", 0.0))))
    defender.damage = roundi(float(defender.damage) * (1.0 + float(village_modifiers.get("defender_damage_multiplier", 0.0))))

func _load_village_progression() -> void:
    var state := v06_integration.store.load_state()
    feedback_settings.apply(state.get("feedback_settings", {}))
    village_progression = V04ProgressionService.new(state.get("v04_progression", {}))
    black_market.from_dict(state.get("black_market", {}))
    if state.has("monster_roster"):
        monster_roster.from_dict(state.monster_roster)
    else:
        monster_roster.recruited = ["ghost", "slime", "mimic", "spider"]
        monster_roster.selected_team = monster_roster.recruited.duplicate()
    monster_roster.capacity = mini(village_den.get_capacity(), MONSTER_HOME_CELLS.size())
    if monster_roster.selected_team.size() > monster_roster.capacity:
        monster_roster.selected_team = monster_roster.selected_team.slice(0, monster_roster.capacity)
    monster_progression.from_dict(state.get("monster_progression", {}))
    labyrinth_modules.from_dict(state.get("labyrinth_modules", {}), village_progression.state.buildings)
    room_deck_selection.from_dict(state.get("room_deck_selection", {}))
    adventurer_intelligence.from_dict(state.get("adventurer_intelligence", {}))
    contextual_tutorial.restore(state.get("contextual_tutorial", {}))
    var labyrinth_modifiers := labyrinth_modules.generator_modifiers()
    labyrinth_generator.wall_density = clampf(0.34 + float(labyrinth_modifiers.density), 0.18, 0.48)
    labyrinth_generator.minimum_loops = 4 + int(labyrinth_modifiers.loops)
    labyrinth_generator.route_gate_count = 3 + int(labyrinth_modifiers.gates)
    var families := {"ghost": "spectral", "slime": "ooze", "mimic": "construct", "spider": "beast"}
    for monster_id in monster_roster.recruited:
        monster_progression.ensure_monster(monster_id, String(families.get(monster_id, "beast")))
    village_modifiers = village_progression.combined_modifiers()
    var market_modifiers := black_market.combined_modifiers()
    for key in market_modifiers:
        village_modifiers[key] = float(village_modifiers.get(key, 0.0)) + float(market_modifiers[key])

func _refresh_adventurer_intelligence() -> void:
    var adventurer := waves.get_adventurer_data()
    var laboratory_level := int(village_progression.state.buildings.get("laboratory", 0))
    var report: Dictionary = adventurer_intelligence.report(adventurer, laboratory_level)
    adventurer_intelligence.record_encounter(adventurer.id)
    var persisted_state := v06_integration.store.load_state()
    persisted_state["adventurer_intelligence"] = adventurer_intelligence.to_dict()
    v06_integration.store.save_state(persisted_state)
    var lines: Array[String] = ["RENSEIGNEMENTS — %s" % String(report.name)]
    for fact in report.visible:
        lines.append("• %s" % String(fact))
    lines.append("? %d donnée(s) inconnue(s)" % int(report.hidden_count))
    intelligence_label.text = "\n".join(lines)
    intelligence_label.tooltip_text = "%s\n\nLe laboratoire révèle une information fiable supplémentaire par niveau." % intelligence_label.text

func _max_defenders() -> int:
    return village_den.get_capacity()

func _starting_gold_adjustment() -> int:
    return int(village_modifiers.get("starting_gold_adjustment", 0)) + roundi(active_biome.rule_value("starting_gold_adjustment", 0.0))

func _monster_respawn_delay(base_delay: float) -> float:
    var speed_bonus := float(village_modifiers.get("monster_respawn_speed_multiplier", 0.0))
    var lair_bonus := float(village_den.level) * 0.08
    return maxf(0.5, base_delay / (1.0 + speed_bonus + lair_bonus))

func _monster_damage_multiplier() -> float:
    return (1.0 + float(village_modifiers.get("monster_damage_multiplier", 0.0))) * v06_integration.event_multiplier("monster_damage_multiplier")

func _monster_speed_multiplier() -> float:
    return v06_integration.event_multiplier("monster_speed_multiplier") * active_biome.rule_value("monster_speed_multiplier", 1.0) * (1.0 + float(run_choice_modifiers.get("monster_speed_multiplier", 0.0)))

func _monster_evasion(archetype_id: StringName) -> float:
    return v06_integration.synergy_bonus("evasion") + float(run_choice_modifiers.get("ghost_evasion", 0.0)) if archetype_id == &"ghost" else 0.0

func _monster_ambush_multiplier(archetype_id: StringName, first_hit: bool) -> float:
    if archetype_id == &"mimic" and first_hit:
        return 1.0 + v06_integration.synergy_bonus("ambush_damage") + float(run_choice_modifiers.get("ambush_damage", 0.0))
    return 1.0

func _slime_slow_multiplier(base_multiplier: float) -> float:
    return base_multiplier * (1.0 - v06_integration.synergy_bonus("enemy_slow") - float(run_choice_modifiers.get("enemy_slow", 0.0)))

func _monster_health_multiplier() -> float:
    return 1.0 + float(village_modifiers.get("monster_health_multiplier", 0.0))

func _monster_progression_multipliers(archetype_id: String) -> Dictionary:
    return monster_progression.stat_multipliers(archetype_id)

func _monster_specific_damage_multiplier(archetype_id: String) -> float:
    return float(monster_progression.stat_multipliers(archetype_id).damage)

func _effect_duration_multiplier() -> float:
    return (1.0 + float(village_modifiers.get("effect_duration_multiplier", 0.0))) * active_biome.rule_value("effect_duration_multiplier", 1.0)

func _spawn_combat_effect(kind: StringName, origin: Vector2, target: Vector2, color: Color, duration: float) -> void:
    if not feedback_settings.particles_enabled:
        return
    if sfx_player != null:
        sfx_player.call("play_event", String(kind), feedback_settings)
    var adjusted_duration := duration * (0.45 if feedback_settings.reduced_motion else 1.0)
    super._spawn_combat_effect(kind, origin, target, color, adjusted_duration)

func _process(delta: float) -> void:
    super._process(delta)
    tactical_powers.tick(delta)
    if emergency_lock_time > 0.0:
        emergency_lock_time = maxf(emergency_lock_time - delta, 0.0)
        if emergency_lock_time <= 0.0:
            door_closed = false
            _recalculate_path()
    if hunt_order_time > 0.0:
        hunt_order_time = maxf(hunt_order_time - delta, 0.0)
        if hunt_order_time <= 0.0 and not hunt_original_behaviours.is_empty():
            monster_behaviours = hunt_original_behaviours.duplicate()
            hunt_original_behaviours.clear()
    _refresh_tactical_power_ui()
    if game_state != GameState.INVASION:
        return
    var cell := _cell_from_world(adventurer_position)
    tactical_heatmap.record(&"traffic", cell)
    adventurer_squad.tick(delta)
    if cell == combo_zone_cell:
        return
    combo_zone_cell = cell
    if slime_trails.has(cell):
        _apply_combo_state("slimed")
    if spider_webs.has(cell):
        _apply_combo_state("webbed")
    if active_biome.active_biome_id == BiomeCatalog.SEWERS:
        _apply_combo_state("wet")

func _on_trap_status_applied(effect_id: StringName, duration: float, strength: float) -> void:
    super._on_trap_status_applied(effect_id, duration, strength)
    var state_by_effect := {&"tar_slow": "tarred", &"frost_slow": "frozen", &"void_slow": "cursed", &"burning": "burning", &"vulnerable": "vulnerable", &"frightened": "frightened"}
    if state_by_effect.has(effect_id):
        _apply_combo_state(String(state_by_effect[effect_id]))

func _on_monster_hit_adventurer(archetype_id: StringName, was_ambush: bool) -> void:
    if archetype_id == &"ghost":
        _apply_combo_state("spectral")
    if was_ambush:
        _apply_combo_state("ambushed")

func _apply_combo_state(state_id: String) -> Dictionary:
    var combo: Dictionary = combo_runtime.apply_state(state_id)
    if combo.is_empty():
        return combo
    var damage := int(combo.damage)
    adventurer_health.take_damage(damage)
    run_stats.total_damage += damage
    tactical_powers.gain_from_combo(damage)
    var result_state := String(combo.get("result", ""))
    if not result_state.is_empty() and not combo_runtime.states.has(result_state):
        combo_runtime.states.append(result_state)
    status_label.text = "COMBO — %s : %d dégâts !" % [String(combo.name), damage]
    _spawn_combat_effect(&"splash", adventurer_position, adventurer_position, Color("ffd166"), 0.55)
    return combo

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_Q:
                _activate_tactical_power("emergency_lock")
                return
            KEY_E:
                _activate_tactical_power("hunt_order")
                return
            KEY_F:
                _activate_tactical_power("trap_overcharge")
                return
            KEY_H:
                _toggle_heatmap()
                return
    super._unhandled_input(event)

func _build_tactical_power_ui() -> void:
    tactical_energy_label = Label.new()
    tactical_energy_label.name = "TacticalEnergyLabel"
    tactical_energy_label.position = Vector2(772, 456)
    tactical_energy_label.size = Vector2(152, 18)
    tactical_energy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    tactical_energy_label.add_theme_font_size_override("font_size", 10)
    add_child(tactical_energy_label)
    var ids := ["emergency_lock", "hunt_order", "trap_overcharge"]
    for index in ids.size():
        var power_id: String = ids[index]
        var power: Dictionary = TacticalPowerRuntimeScript.POWERS[power_id]
        var button := Button.new()
        button.position = Vector2(772, 476 + index * 29)
        button.size = Vector2(152, 26)
        button.text = "[%s] %s" % [String(power.shortcut), String(power.name)]
        button.add_theme_font_size_override("font_size", 9)
        button.pressed.connect(_activate_tactical_power.bind(power_id))
        add_child(button)
        tactical_power_buttons[power_id] = button
    _refresh_tactical_power_ui()

func _refresh_tactical_power_ui() -> void:
    if tactical_energy_label == null:
        return
    tactical_energy_label.text = "PUISSANCE %.0f/%d" % [tactical_powers.energy, int(TacticalPowerRuntimeScript.MAX_ENERGY)]
    tactical_energy_label.visible = game_state == GameState.INVASION
    for power_id in tactical_power_buttons:
        var button := tactical_power_buttons[power_id] as Button
        button.visible = game_state == GameState.INVASION
        button.disabled = tactical_powers.blocked_reason(power_id) != "Disponible."
        button.tooltip_text = "%s Coût : %.0f." % [tactical_powers.blocked_reason(power_id), float(TacticalPowerRuntimeScript.POWERS[power_id].cost)]

func _activate_tactical_power(power_id: String) -> void:
    if game_state != GameState.INVASION:
        status_label.text = "Les pouvoirs tactiques ne sont disponibles que pendant l'invasion."
        return
    var result := tactical_powers.activate(power_id)
    if not bool(result.get("ok", false)):
        status_label.text = tactical_powers.blocked_reason(power_id)
        return
    match power_id:
        "emergency_lock":
            door_closed = true
            emergency_lock_time = float(result.duration)
            _recalculate_path()
        "hunt_order":
            if hunt_original_behaviours.is_empty():
                hunt_original_behaviours = monster_behaviours.duplicate()
            for index in monster_behaviours.size():
                monster_behaviours[index] = PacmanLoopRules.Behaviour.CHASER
            hunt_order_time = float(result.duration)
        "trap_overcharge":
            var target_cell := Vector2i(-1, -1)
            if traps.has(inspected_defense_cell):
                target_cell = inspected_defense_cell
            elif not traps.is_empty():
                target_cell = Vector2i(traps.keys()[0])
            if target_cell != Vector2i(-1, -1):
                var trap := traps[target_cell] as SpikeTrap
                trap.cooldown_left = 0.0
                _spawn_combat_effect(&"splash", _world_from_cell(target_cell), _world_from_cell(target_cell), Color("ffe066"), 0.45)
    status_label.text = "%s activé." % String(TacticalPowerRuntimeScript.POWERS[power_id].name)
    _refresh_tactical_power_ui()

func _on_trap_triggered_for_power(damage: int) -> void:
    tactical_powers.gain_from_trap(damage)
    tactical_heatmap.record(&"triggers", _cell_from_world(adventurer_position))
    tactical_heatmap.record(&"damage", _cell_from_world(adventurer_position), damage)

func _toggle_heatmap() -> void:
    heatmap_visible = not heatmap_visible
    if heatmap_button:
        heatmap_button.text = "[H] Masquer la carte" if heatmap_visible else "[H] Carte tactique"
    queue_redraw()

func _configure_room_rules() -> void:
    room_rules.room_rules.clear()
    var rules: Array[StringName] = [&"silence", &"darkness", &"fragile_floor", &"altar", &"prison", &"mana_reserve"]
    var cells: Array[Vector2i] = [Vector2i(3, 3), Vector2i(6, 3), Vector2i(9, 3), Vector2i(3, 7), Vector2i(6, 7), Vector2i(9, 7)]
    for index in mini(rules.size(), cells.size()):
        room_rules.assign(cells[index], rules[index])

func _draw() -> void:
    super._draw()
    if not heatmap_visible:
        return
    for x in GRID_SIZE.x:
        for y in GRID_SIZE.y:
            var cell := Vector2i(x, y)
            var value := tactical_heatmap.intensity(&"traffic", cell)
            if value > 0.0:
                draw_rect(Rect2(GRID_ORIGIN + Vector2(cell) * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE)), Color(0.2 + value * 0.7, 0.25, 0.85 - value * 0.5, 0.18 + value * 0.3), true)

func _wave_reward_multiplier() -> float:
    return 1.0 + float(run_choice_modifiers.get("permanent_reward_multiplier", 0.0))

func _on_trap_placed() -> void:
    v06_integration.record_trap_placed()
    _refresh_v06_hud()

func record_v06_wall_placed() -> void:
    v06_integration.record_wall_placed()
    _refresh_v06_hud()

func _offer_run_choices() -> void:
    current_choice_offer.clear()
    for choice: Dictionary in choice_engine.offer(v06_integration.run_seed, waves.current_wave, RogueliteChoiceEngine.CHOICES.size()):
        if not selected_choice_ids.has(StringName(choice.id)):
            current_choice_offer.append(choice)
        if current_choice_offer.size() >= 3:
            break
    if current_choice_offer.is_empty():
        pending_run_choice = false
        return
    pending_run_choice = true
    result_summary.size.y = 232
    result_summary.text += "\n\nChoisissez une amélioration pour la suite :"
    for index in choice_buttons.size():
        var button := choice_buttons[index]
        var available := index < current_choice_offer.size()
        button.visible = available
        button.disabled = not available
        if available:
            var choice: Dictionary = current_choice_offer[index]
            button.text = String(choice.label)
            button.tooltip_text = String(choice.description)
    start_button.disabled = true
    status_label.text = "La victoire vous accorde une amélioration de run."

func _select_run_choice(index: int) -> void:
    if not pending_run_choice or index < 0 or index >= current_choice_offer.size():
        return
    var choice: Dictionary = current_choice_offer[index]
    var choice_id := StringName(choice.id)
    selected_choice_ids.append(choice_id)
    for key: Variant in choice.get("modifiers", {}).keys():
        run_choice_modifiers[key] = float(run_choice_modifiers.get(key, 0.0)) + float(choice.modifiers[key])
    v06_integration.apply_choice_tags(choice.get("tags", []))
    pending_run_choice = false
    start_button.disabled = false
    for button_index in choice_buttons.size():
        choice_buttons[button_index].disabled = true
        if button_index == index:
            choice_buttons[button_index].text = "✓ %s" % String(choice.label)
    loop_rules.door_cooldown = 2.0 * maxf(0.2, 1.0 + float(run_choice_modifiers.get("door_cooldown_multiplier", 0.0)))
    result_summary.text += "\nAmélioration choisie : %s — %s" % [String(choice.label), String(choice.description)]
    status_label.text = "%s activé. Vous pouvez préparer la prochaine vague." % String(choice.label)
    _refresh_active_gameplay_modifiers()
    _refresh_v06_hud()

func _set_choice_buttons_visible(value: bool) -> void:
    for button in choice_buttons:
        button.visible = value
    if not value and start_button:
        start_button.disabled = false

func _choice_effect_entries() -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    for choice_id in selected_choice_ids:
        for choice: Dictionary in RogueliteChoiceEngine.CHOICES:
            if StringName(choice.id) == choice_id:
                entries.append({"kind": "choice", "name": String(choice.label), "description": String(choice.description)})
                break
    return entries

func _refresh_v06_hud() -> void:
    if not objectives_label or not modifiers_label:
        return
    var snapshot := v06_integration.hud_snapshot()
    objectives_label.text = "OBJECTIFS\n%s" % ("\n".join(snapshot.challenges) if not snapshot.challenges.is_empty() else "Aucun")
    _refresh_effect_rows(_village_effect_entries() + _choice_effect_entries() + snapshot.effect_entries)
    _refresh_event_history(snapshot.event_history)

func _announce_event(announcement: Dictionary) -> void:
    event_banner.text = "⚡ %s · %d vague(s)" % [String(announcement.title), int(announcement.duration)]
    event_banner.modulate = Color.WHITE
    event_banner.visible = true
    var tween := create_tween()
    tween.tween_interval(2.2)
    tween.tween_property(event_banner, "modulate:a", 0.0, 0.4)
    tween.tween_callback(func(): event_banner.visible = false)

func _refresh_event_history(history: Array) -> void:
    history_button.text = "HISTORIQUE (%d)" % history.size()
    var lines: Array[String] = []
    for event_id in history:
        var definition := v06_integration.events.catalog.get_event(String(event_id))
        lines.append("• %s — %s" % [String(definition.get("name", event_id)), String(definition.get("description", ""))])
    history_button.tooltip_text = "\n".join(lines) if not lines.is_empty() else "Aucun événement déclenché pendant cette run."

func _show_event_history() -> void:
    status_label.text = "HISTORIQUE DES ÉVÉNEMENTS\n%s" % history_button.tooltip_text

func _build_defense_inspector() -> void:
    defense_inspector = PanelContainer.new()
    defense_inspector.name = "DefenseInspector"
    defense_inspector.position = Vector2(768, 104)
    defense_inspector.size = Vector2(160, 318)
    defense_inspector.visible = false
    add_child(defense_inspector)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 6)
    defense_inspector.add_child(column)
    var heading := Label.new()
    heading.text = "DÉFENSE"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    column.add_child(heading)
    defense_inspector_text = Label.new()
    defense_inspector_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    defense_inspector_text.custom_minimum_size = Vector2(150, 155)
    defense_inspector_text.add_theme_font_size_override("font_size", 10)
    column.add_child(defense_inspector_text)
    var power := Button.new()
    power.text = "[U] Puissance"
    power.pressed.connect(func(): _upgrade_inspected_defense("power"))
    column.add_child(power)
    var tempo := Button.new()
    tempo.text = "[I] Cadence"
    tempo.pressed.connect(func(): _upgrade_inspected_defense("tempo"))
    column.add_child(tempo)
    var recycle := Button.new()
    recycle.text = "[X] Recycler"
    recycle.pressed.connect(_recycle_inspected_defense)
    column.add_child(recycle)
    var close := Button.new()
    close.text = "Fermer"
    close.pressed.connect(func(): defense_inspector.visible = false)
    column.add_child(close)

func _on_defense_placed(cell: Vector2i, kind: String, cost: int, object: Node) -> void:
    var base_stats := {}
    if kind == "trap":
        var trap := object as SpikeTrap
        base_stats = {"damage": trap.damage, "cooldown": trap.cooldown_duration, "range": 1.0}
    else:
        if kind == "defender":
            var defender := object as Defender
            base_stats = {"damage": defender.damage, "cooldown": defender.cooldown, "range": defender.attack_range_cells}
        else:
            base_stats = {"damage": 0, "cooldown": 1.0, "range": 1.0}
    defense_evolution.register(cell, kind, cost, base_stats)

func _inspect_defense(cell: Vector2i) -> void:
    if defense_evolution.inspect(cell).is_empty():
        return
    inspected_defense_cell = cell
    defense_inspector.visible = true
    defense_inspector.move_to_front()
    _refresh_defense_inspector()

func _refresh_defense_inspector() -> void:
    var record := defense_evolution.inspect(inspected_defense_cell)
    if record.is_empty():
        defense_inspector.visible = false
        return
    var stats := defense_evolution.evolved_stats(inspected_defense_cell)
    var branch := "Aucune" if String(record.branch).is_empty() else String(DefenseEvolutionScript.BRANCHES[record.branch].name)
    var next_cost := 18 + int(record.level) * 12
    var refund := floori(float(int(record.base_cost) + int(record.spent)) * DefenseEvolutionScript.REFUND_RATE)
    defense_inspector_text.text = "%s · case %s\nNiveau %d/%d\nBranche : %s\nDégâts : %d\nPortée : %.1f\nRecharge : %.2f s\nProchaine amélioration : %d or\nRecyclage : %d or" % [String(record.kind).capitalize(), inspected_defense_cell, int(record.level), DefenseEvolutionScript.MAX_LEVEL, branch, int(stats.damage), float(stats.range), float(stats.cooldown), next_cost, refund]

func _upgrade_inspected_defense(branch: String) -> void:
    if inspected_defense_cell == Vector2i(-1, -1):
        return
    var result := defense_evolution.upgrade(inspected_defense_cell, branch, economy.current_gold)
    if not bool(result.get("ok", false)):
        status_label.text = "Amélioration refusée : or insuffisant, branche verrouillée ou niveau maximum."
        return
    economy.spend(int(result.cost))
    var stats: Dictionary = result.stats
    if traps.has(inspected_defense_cell):
        var trap := traps[inspected_defense_cell] as SpikeTrap
        trap.damage = int(stats.damage)
        trap.cooldown_duration = float(stats.cooldown)
    elif defenders.has(inspected_defense_cell):
        var defender := defenders[inspected_defense_cell] as Defender
        defender.damage = int(stats.damage)
        defender.cooldown = float(stats.cooldown)
        defender.attack_range_cells = float(stats.range)
    elif walls.has(inspected_defense_cell):
        status_label.text = "Mur renforcé : remboursement amélioré au recyclage."
    status_label.text = "Défense améliorée : branche %s." % branch
    _refresh_defense_inspector()

func _recycle_inspected_defense() -> void:
    var result := defense_evolution.recycle(inspected_defense_cell)
    if not bool(result.get("ok", false)):
        return
    if traps.has(inspected_defense_cell):
        (traps[inspected_defense_cell] as Node).queue_free()
        traps.erase(inspected_defense_cell)
    elif defenders.has(inspected_defense_cell):
        (defenders[inspected_defense_cell] as Node).queue_free()
        defenders.erase(inspected_defense_cell)
    elif walls.has(inspected_defense_cell):
        if not _remove_evolved_wall(inspected_defense_cell):
            return
    economy.add_gold(int(result.refund))
    status_label.text = "Défense recyclée : +%d or (50 %% de l’investissement)." % int(result.refund)
    inspected_defense_cell = Vector2i(-1, -1)
    defense_inspector.visible = false
    _refresh_build_ui()
    queue_redraw()

func _refresh_effect_rows(entries: Array) -> void:
    for row in effect_rows:
        modifiers_list.remove_child(row)
        row.queue_free()
    effect_rows.clear()
    if entries.is_empty():
        entries = [{"name": "Aucun", "description": "Aucun modificateur n'est actif pour cette vague."}]
    for entry: Dictionary in entries:
        var row := Button.new()
        row.text = String(entry.name)
        row.tooltip_text = String(entry.description)
        row.flat = true
        row.alignment = HORIZONTAL_ALIGNMENT_LEFT
        row.custom_minimum_size = Vector2(156, 20)
        row.mouse_default_cursor_shape = Control.CURSOR_HELP
        row.add_theme_font_size_override("font_size", 12)
        row.add_theme_color_override("font_hover_color", Color("ffe08a"))
        var hover_style := StyleBoxFlat.new()
        hover_style.bg_color = Color("273044d9")
        hover_style.corner_radius_top_left = 4
        hover_style.corner_radius_top_right = 4
        hover_style.corner_radius_bottom_left = 4
        hover_style.corner_radius_bottom_right = 4
        row.add_theme_stylebox_override("hover", hover_style)
        modifiers_list.add_child(row)
        effect_rows.append(row)

func _village_effect_entries() -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    for line in _village_effect_lines():
        entries.append({"kind": "village", "name": line, "description": "Bonus permanent accordé par les améliorations du village."})
    return entries

func _refresh_active_gameplay_modifiers() -> void:
    for trap: SpikeTrap in traps.values():
        trap.configure(TrapCatalogScript.definition(trap.trap_id))
        _configure_trap(trap)
    for index in mobile_monsters.size():
        var progression := _monster_progression_multipliers(active_monster_archetypes[index].archetype_id)
        mobile_monsters[index].move_speed = active_monster_archetypes[index].base_speed * _monster_speed_multiplier() * float(progression.speed)

func _village_effect_lines() -> Array[String]:
    var lines: Array[String] = ["Tanière : %d défenseurs" % _max_defenders()]
    var forge_level := int(village_progression.state.buildings.get("forge", 0))
    var laboratory_level := int(village_progression.state.buildings.get("laboratory", 0))
    var graveyard_level := int(village_progression.state.buildings.get("graveyard", 0))
    if forge_level > 0:
        lines.append("Forge : +%d%% pièges, %d modèles" % [roundi(float(village_modifiers.get("trap_damage_multiplier", 0.0)) * 100.0), unlocked_trap_ids.size()])
    if laboratory_level > 0:
        lines.append("Labo : +%d%% effets" % roundi(float(village_modifiers.get("effect_duration_multiplier", 0.0)) * 100.0))
    if graveyard_level > 0:
        lines.append("Cimetière : +%d%% retour" % roundi(float(village_modifiers.get("monster_respawn_speed_multiplier", 0.0)) * 100.0))
    lines.append_array(black_market.active_effect_summaries())
    return lines

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
