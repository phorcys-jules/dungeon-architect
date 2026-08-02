extends "res://scripts/dungeon_invasion_controller.gd"
class_name GameController

const RunEndControllerScript := preload("res://scripts/core/run_end_controller.gd")
const AdventurerIntelligenceScript := preload("res://scripts/meta/adventurer_intelligence.gd")

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
var pending_run_choice := false

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
    objectives_label.add_theme_font_size_override("font_size", 12)
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
    _set_choice_buttons_visible(false)
    result_summary.size.y = 318
    var announcement := v06_integration.start_wave(waves.current_wave, active_biome.active_biome_id)
    super._prepare_current_wave()
    _refresh_adventurer_intelligence()
    var village_health := 1.0 + float(village_modifiers.get("adventurer_health_multiplier", 0.0))
    adventurer_health.max_health = maxi(1, roundi(float(waves.get_adventurer_health()) * v06_integration.adventurer_health_multiplier() * village_health))
    adventurer_health.reset()
    if not announcement.is_empty():
        status_label.text += "\nÉvénement : %s — %s" % [String(announcement.title), String(announcement.body)]
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
    return int(village_modifiers.get("starting_gold_adjustment", 0))

func _monster_respawn_delay(base_delay: float) -> float:
    var speed_bonus := float(village_modifiers.get("monster_respawn_speed_multiplier", 0.0))
    var lair_bonus := float(village_den.level) * 0.08
    return maxf(0.5, base_delay / (1.0 + speed_bonus + lair_bonus))

func _monster_damage_multiplier() -> float:
    return (1.0 + float(village_modifiers.get("monster_damage_multiplier", 0.0))) * v06_integration.event_multiplier("monster_damage_multiplier")

func _monster_speed_multiplier() -> float:
    return v06_integration.event_multiplier("monster_speed_multiplier") * (1.0 + float(run_choice_modifiers.get("monster_speed_multiplier", 0.0)))

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
    return 1.0 + float(village_modifiers.get("effect_duration_multiplier", 0.0))

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
