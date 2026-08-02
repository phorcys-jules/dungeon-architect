extends Node2D

const HealthComponentScript := preload("res://scripts/components/health_component.gd")
const SpikeTrapScript := preload("res://scripts/traps/spike_trap.gd")
const DefenderScript := preload("res://scripts/monsters/defender.gd")
const RunStatsScript := preload("res://scripts/core/run_stats.gd")
const EconomyScript := preload("res://scripts/core/economy.gd")
const WaveManagerScript := preload("res://scripts/core/wave_manager.gd")
const CharacterAnimationRuntimeScript := preload("res://scripts/presentation/character_animation_runtime.gd")
const MonsterSprite := preload("res://assets/sprites/characters/animations/monster_imp_walk.png")
const TREASURE_TEXTURE := preload("res://assets/sprites/collectibles/treasure_chest.png")
const ADVENTURER_TEXTURES := {
    "scout": preload("res://assets/sprites/characters/animations/adventurer_scout_walk.png"),
    "warrior": preload("res://assets/sprites/characters/animations/adventurer_warrior_walk.png"),
    "champion": preload("res://assets/sprites/characters/animations/adventurer_knight_walk.png"),
}

const GRID_SIZE := Vector2i(15, 10)
const CELL_SIZE := 48
const GRID_ORIGIN := Vector2(48, 96)
const ENTRANCE := Vector2i(0, 5)
const TREASURE := Vector2i(14, 5)
const DOOR := Vector2i(7, 5)
const MOVE_SPEED := 150.0
const PREPARATION_DURATION := 15.0
const STARTING_GOLD := 100
const SPIKE_TRAP_COST := 25
const DEFENDER_COST := 40
const DOOR_COST := 10
const CHARACTER_DRAW_SIZE := Vector2(48, 48)
const CHARACTER_FRAME_SIZE := Vector2(128, 128)
const COLLECTIBLE_DRAW_SIZE := Vector2(44, 44)

enum GameState { PREPARATION, INVASION, WAVE_RESULT, CAMPAIGN_FINISHED }
enum BuildMode { SPIKE_TRAP, DEFENDER }

var astar := AStarGrid2D.new()
var walls: Array[Vector2i] = []
var traps: Dictionary = {}
var defenders: Dictionary = {}
var build_mode := BuildMode.SPIKE_TRAP
var door_closed := false
var door_purchased := false
var adventurer_position := Vector2.ZERO
var character_animation_time := 0.0
var adventurer_facing := 1.0
var adventurer_damage_flash := 0.0
var adventurer_attack_flash := 0.0
var adventurer_attack_direction := Vector2.RIGHT
var defender_attack_flashes: Dictionary = {}
var combat_effects: Array[Dictionary] = []
var path: Array[Vector2] = []
var path_index := 0
var game_state := GameState.PREPARATION
var preparation_time_left := PREPARATION_DURATION
var adventurer_health: HealthComponent
var run_stats: RunStats = RunStatsScript.new()
var economy: Economy = EconomyScript.new()
var waves: WaveManager = WaveManagerScript.new()

var status_label: Label
var phase_label: Label
var countdown_label: Label
var wave_label: Label
var health_label: Label
var build_label: Label
var gold_label: Label
var door_button: Button
var start_button: Button
var trap_button: Button
var defender_button: Button
var result_panel: Panel
var result_title: Label
var result_summary: RichTextLabel

func _ready() -> void:
    _build_level()
    _configure_pathfinding()
    _build_health_component()
    _build_interface()
    economy.starting_gold = STARTING_GOLD
    economy.gold_changed.connect(_on_gold_changed)
    _start_new_campaign()
    queue_redraw()

func _process(delta: float) -> void:
    _tick_combat_presentation(delta)
    for trap: SpikeTrap in traps.values():
        trap.tick(delta)
    for defender: Defender in defenders.values():
        defender.tick(delta)
        if game_state == GameState.INVASION and not adventurer_health.is_dead:
            defender.try_attack(adventurer_position, adventurer_health, CELL_SIZE)

    if game_state == GameState.PREPARATION:
        preparation_time_left = maxf(preparation_time_left - delta, 0.0)
        _refresh_phase_ui()
        if preparation_time_left <= 0.0:
            _start_invasion()
        queue_redraw()
        return

    if game_state != GameState.INVASION or adventurer_health.is_dead:
        return

    run_stats.tick(delta)
    if path_index >= path.size():
        return

    var target := path[path_index]
    adventurer_facing = CharacterAnimationRuntimeScript.facing_sign(target.x - adventurer_position.x, adventurer_facing)
    adventurer_position = adventurer_position.move_toward(target, MOVE_SPEED * _current_adventurer_speed_multiplier() * delta)
    if adventurer_position.distance_to(target) < 1.0:
        adventurer_position = target
        _trigger_trap_at(_cell_from_world(adventurer_position))
        path_index += 1
        if path_index >= path.size() and not adventurer_health.is_dead:
            _finish_campaign(false, "Le trésor a été pillé pendant la vague %d." % waves.current_wave)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_1:
                _set_build_mode(BuildMode.SPIKE_TRAP)
            KEY_2:
                _set_build_mode(BuildMode.DEFENDER)
            KEY_SPACE, KEY_ENTER:
                _on_primary_button_pressed()
            KEY_D:
                _toggle_door()
        return
    if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
        return
    var cell := _cell_from_world(event.position)
    if cell == DOOR:
        _toggle_door()
    elif game_state == GameState.PREPARATION:
        if build_mode == BuildMode.SPIKE_TRAP:
            _place_spike_trap(cell)
        else:
            _place_defender(cell)

func _draw() -> void:
    _draw_grid()
    _draw_level_objects()
    _draw_traps()
    _draw_defenders()
    _draw_adventurer()
    _draw_combat_effects()

func _build_level() -> void:
    for x in range(2, 13):
        if x != DOOR.x:
            walls.append(Vector2i(x, 4))
            walls.append(Vector2i(x, 6))
    walls.append_array([Vector2i(5, 1), Vector2i(5, 2), Vector2i(5, 3), Vector2i(9, 7), Vector2i(9, 8), Vector2i(11, 2), Vector2i(12, 2), Vector2i(13, 2)])

func _configure_pathfinding() -> void:
    astar.region = Rect2i(Vector2i.ZERO, GRID_SIZE)
    astar.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
    astar.offset = Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
    astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    astar.update()
    for wall in walls:
        astar.set_point_solid(wall, true)

func _build_health_component() -> void:
    adventurer_health = HealthComponentScript.new()
    adventurer_health.health_changed.connect(_on_adventurer_health_changed)
    adventurer_health.damaged.connect(_on_adventurer_damaged)
    adventurer_health.died.connect(_on_adventurer_died)
    add_child(adventurer_health)

func _build_interface() -> void:
    var header_panel := Panel.new()
    header_panel.position = Vector2(24, 14)
    header_panel.size = Vector2(912, 72)
    header_panel.add_theme_stylebox_override("panel", _panel_style(Color("111621e8"), Color("37445d"), 10))
    add_child(header_panel)

    var title := Label.new()
    title.text = "DUNGEON ARCHITECT  •  v0.6 ALPHA"
    title.position = Vector2(42, 22)
    title.size = Vector2(520, 32)
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", Color("f3e9d2"))
    add_child(title)

    phase_label = Label.new()
    phase_label.position = Vector2(42, 56)
    phase_label.size = Vector2(205, 24)
    phase_label.add_theme_font_size_override("font_size", 14)
    phase_label.add_theme_color_override("font_color", Color("a9bdd6"))
    add_child(phase_label)

    countdown_label = Label.new()
    countdown_label.position = Vector2(250, 56)
    countdown_label.size = Vector2(170, 24)
    countdown_label.add_theme_font_size_override("font_size", 14)
    countdown_label.add_theme_color_override("font_color", Color("f6c177"))
    add_child(countdown_label)

    wave_label = Label.new()
    wave_label.position = Vector2(425, 56)
    wave_label.size = Vector2(205, 24)
    wave_label.add_theme_font_size_override("font_size", 14)
    wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    add_child(wave_label)

    gold_label = Label.new()
    gold_label.position = Vector2(638, 56)
    gold_label.size = Vector2(100, 24)
    gold_label.add_theme_font_size_override("font_size", 14)
    gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    gold_label.add_theme_color_override("font_color", Color("ffd166"))
    add_child(gold_label)

    var sidebar_panel := Panel.new()
    sidebar_panel.position = Vector2(760, 96)
    sidebar_panel.size = Vector2(176, 480)
    sidebar_panel.add_theme_stylebox_override("panel", _panel_style(Color("111621ee"), Color("37445d"), 10))
    add_child(sidebar_panel)

    var footer_panel := Panel.new()
    footer_panel.position = Vector2(24, 584)
    footer_panel.size = Vector2(912, 48)
    footer_panel.add_theme_stylebox_override("panel", _panel_style(Color("111621f2"), Color("37445d"), 8))
    add_child(footer_panel)

    status_label = Label.new()
    status_label.position = Vector2(38, 588)
    status_label.size = Vector2(884, 20)
    status_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    status_label.add_theme_font_size_override("font_size", 13)
    status_label.add_theme_color_override("font_color", Color("d8dee9"))
    add_child(status_label)

    health_label = Label.new()
    health_label.position = Vector2(38, 608)
    health_label.size = Vector2(230, 20)
    health_label.add_theme_font_size_override("font_size", 12)
    health_label.add_theme_color_override("font_color", Color("7bd389"))
    add_child(health_label)

    build_label = Label.new()
    build_label.position = Vector2(276, 608)
    build_label.size = Vector2(646, 20)
    build_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    build_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    build_label.add_theme_font_size_override("font_size", 12)
    add_child(build_label)

    trap_button = Button.new()
    trap_button.position = Vector2(772, 444)
    trap_button.size = Vector2(152, 34)
    _style_action_button(trap_button, Color("6f4b8b"))
    trap_button.pressed.connect(func(): _set_build_mode(BuildMode.SPIKE_TRAP))
    add_child(trap_button)

    defender_button = Button.new()
    defender_button.position = Vector2(772, 486)
    defender_button.size = Vector2(152, 34)
    _style_action_button(defender_button, Color("456990"))
    defender_button.pressed.connect(func(): _set_build_mode(BuildMode.DEFENDER))
    add_child(defender_button)

    door_button = Button.new()
    door_button.position = Vector2(772, 528)
    door_button.size = Vector2(152, 34)
    _style_action_button(door_button, Color("8d5b4c"))
    door_button.pressed.connect(_toggle_door)
    add_child(door_button)

    start_button = Button.new()
    start_button.position = Vector2(752, 28)
    start_button.size = Vector2(170, 44)
    _style_action_button(start_button, Color("3d6b66"))
    start_button.pressed.connect(_on_primary_button_pressed)
    add_child(start_button)

    result_panel = Panel.new()
    result_panel.position = Vector2(210, 104)
    result_panel.size = Vector2(540, 472)
    result_panel.add_theme_stylebox_override("panel", _panel_style(Color("10141af7"), Color("7180a4"), 14, 2))
    result_panel.visible = false
    add_child(result_panel)

    result_title = Label.new()
    result_title.position = Vector2(28, 22)
    result_title.size = Vector2(484, 42)
    result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    result_title.add_theme_font_size_override("font_size", 28)
    result_panel.add_child(result_title)

    result_summary = RichTextLabel.new()
    result_summary.position = Vector2(32, 76)
    result_summary.size = Vector2(476, 318)
    result_summary.fit_content = false
    result_summary.scroll_active = true
    result_summary.add_theme_font_size_override("normal_font_size", 16)
    result_summary.add_theme_color_override("default_color", Color("e5e9f0"))
    result_panel.add_child(result_summary)

func _panel_style(color: Color, border_color: Color, radius: int, border_width: int = 1) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color
    style.border_color = border_color
    style.set_border_width_all(border_width)
    style.set_corner_radius_all(radius)
    return style

func _style_action_button(button: Button, accent: Color) -> void:
    var normal := _panel_style(accent.darkened(0.35), accent, 7)
    var hover := _panel_style(accent.darkened(0.15), accent.lightened(0.2), 7, 2)
    var pressed := _panel_style(accent.darkened(0.5), accent.lightened(0.1), 7, 2)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_font_size_override("font_size", 13)

func _start_new_campaign() -> void:
    waves.reset()
    economy.reset()
    for trap: SpikeTrap in traps.values():
        trap.queue_free()
    for defender: Defender in defenders.values():
        defender.queue_free()
    traps.clear()
    defenders.clear()
    defender_attack_flashes.clear()
    combat_effects.clear()
    door_closed = false
    door_purchased = false
    astar.set_point_solid(DOOR, false)
    _prepare_current_wave()

func _prepare_current_wave() -> void:
    game_state = GameState.PREPARATION
    preparation_time_left = PREPARATION_DURATION
    adventurer_position = _world_from_cell(ENTRANCE)
    adventurer_health.max_health = waves.get_adventurer_health()
    adventurer_health.reset()
    run_stats.reset()
    path.clear()
    path_index = 0
    result_panel.visible = false
    build_mode = BuildMode.SPIKE_TRAP
    for trap: SpikeTrap in traps.values():
        trap.reset()
    for defender: Defender in defenders.values():
        defender.reset()
    defender_attack_flashes.clear()
    combat_effects.clear()
    adventurer_attack_flash = 0.0
    status_label.text = "Préparez les défenses pour %s." % waves.get_label()
    _refresh_all_ui()
    queue_redraw()

func _start_invasion() -> void:
    if game_state != GameState.PREPARATION:
        return
    game_state = GameState.INVASION
    _recalculate_path()
    _refresh_all_ui()

func _on_primary_button_pressed() -> void:
    match game_state:
        GameState.PREPARATION:
            _start_invasion()
        GameState.WAVE_RESULT:
            _prepare_current_wave()
        GameState.CAMPAIGN_FINISHED:
            _start_new_campaign()
        GameState.INVASION:
            _finish_campaign(false, "La campagne a été abandonnée.")

func _set_build_mode(mode: BuildMode) -> void:
    if game_state != GameState.PREPARATION:
        return
    build_mode = mode
    status_label.text = "Mode de construction modifié."
    _refresh_build_ui()

func _place_spike_trap(cell: Vector2i) -> void:
    if not _is_valid_build_cell(cell):
        status_label.text = "Placement impossible sur cette case."
        return
    if not economy.spend(SPIKE_TRAP_COST):
        status_label.text = "Or insuffisant pour ce piège."
        return
    var trap: SpikeTrap = SpikeTrapScript.new()
    trap.setup(cell)
    _configure_trap(trap)
    trap.triggered.connect(func(damage: int): run_stats.record_trap(damage); status_label.text = "Piège déclenché : %d dégâts." % damage)
    add_child(trap)
    traps[cell] = trap
    _on_trap_placed()
    status_label.text = "Piège placé pour %d or." % SPIKE_TRAP_COST
    _refresh_build_ui()
    queue_redraw()

func _place_defender(cell: Vector2i) -> void:
    if not _is_valid_build_cell(cell):
        status_label.text = "Placement impossible sur cette case."
        return
    if not economy.spend(DEFENDER_COST):
        status_label.text = "Or insuffisant pour ce défenseur."
        return
    var defender: Defender = DefenderScript.new()
    defender.setup(cell, _world_from_cell(cell))
    _configure_defender(defender)
    defender.attacked.connect(func(damage: int): _on_defender_attacked(cell, damage))
    add_child(defender)
    defenders[cell] = defender
    status_label.text = "Défenseur placé pour %d or." % DEFENDER_COST
    _refresh_build_ui()
    queue_redraw()

func _is_valid_build_cell(cell: Vector2i) -> bool:
    return _is_inside_grid(cell) and cell != ENTRANCE and cell != TREASURE and cell != DOOR and not walls.has(cell) and not traps.has(cell) and not defenders.has(cell)

func _trigger_trap_at(cell: Vector2i) -> void:
    if traps.has(cell):
        (traps[cell] as SpikeTrap).try_trigger(adventurer_health)

func _toggle_door() -> void:
    if game_state != GameState.PREPARATION:
        return
    if not door_closed and not door_purchased:
        if not economy.spend(DOOR_COST):
            status_label.text = "Or insuffisant pour verrouiller la porte."
            return
        door_purchased = true
    door_closed = not door_closed
    astar.set_point_solid(DOOR, door_closed)
    status_label.text = "Porte verrouillée." if door_closed else "Porte ouverte."
    _refresh_all_ui()
    queue_redraw()

func _on_gold_changed(current_gold: int) -> void:
    if gold_label:
        gold_label.text = "Or : %d" % current_gold
    _refresh_build_ui()

func _on_adventurer_health_changed(current_health: int, max_health: int) -> void:
    if health_label:
        health_label.text = "Aventurier : %d / %d PV" % [current_health, max_health]
    queue_redraw()

func _on_adventurer_died() -> void:
    if game_state != GameState.INVASION:
        return
    var reward := waves.get_wave_reward()
    economy.add_gold(reward)
    if waves.has_next_wave():
        var completed_wave := waves.current_wave
        waves.advance()
        game_state = GameState.WAVE_RESULT
        result_title.text = "VAGUE %d RÉUSSIE" % completed_wave
        result_title.modulate = Color("63d471")
        result_summary.text = run_stats.summary() + "\nRécompense : +%d or\nProchaine : %s" % [reward, waves.get_label()]
        result_panel.visible = true
        status_label.text = "Les défenses et l'or sont conservés."
        _refresh_all_ui()
    else:
        _finish_campaign(true, "Les cinq vagues ont été repoussées.")

func _finish_campaign(victory: bool, message: String) -> void:
    if game_state == GameState.CAMPAIGN_FINISHED:
        return
    game_state = GameState.CAMPAIGN_FINISHED
    path.clear()
    run_stats.finish("VICTOIRE" if victory else "DÉFAITE")
    status_label.text = message
    result_title.text = "CAMPAGNE GAGNÉE" if victory else "CAMPAGNE PERDUE"
    result_title.modulate = Color("63d471") if victory else Color("ed6a5a")
    result_summary.text = run_stats.summary() + "\nVague atteinte : %d / %d\nOr restant : %d" % [waves.current_wave, WaveManager.MAX_WAVES, economy.current_gold]
    result_panel.visible = true
    _refresh_all_ui()
    queue_redraw()

func _recalculate_path() -> void:
    var start_cell := _cell_from_world(adventurer_position)
    if not _is_inside_grid(start_cell):
        start_cell = ENTRANCE
    var cell_path := astar.get_id_path(start_cell, TREASURE)
    path.clear()
    path_index = 0
    for cell in cell_path:
        path.append(_world_from_cell(cell))
    if path.size() > 1:
        path.remove_at(0)
    if path.is_empty():
        _on_adventurer_died()
    else:
        status_label.text = "%s : l'aventurier avance vers le trésor." % waves.get_label()

func _refresh_all_ui() -> void:
    _refresh_phase_ui()
    _refresh_build_ui()
    _refresh_door_ui()
    if wave_label:
        wave_label.text = waves.get_label()

func _refresh_phase_ui() -> void:
    if not phase_label or not countdown_label or not start_button:
        return
    match game_state:
        GameState.PREPARATION:
            phase_label.text = "Phase : PRÉPARATION"
            countdown_label.text = "Départ dans %d s" % ceili(preparation_time_left)
            start_button.text = "Lancer la vague"
        GameState.INVASION:
            phase_label.text = "Phase : INVASION"
            countdown_label.text = ""
            start_button.text = "Abandonner"
        GameState.WAVE_RESULT:
            phase_label.text = "Phase : RÉCOMPENSE"
            countdown_label.text = ""
            start_button.text = "Préparer la suite"
        GameState.CAMPAIGN_FINISHED:
            phase_label.text = "Phase : TERMINÉE"
            countdown_label.text = ""
            start_button.text = "Nouvelle campagne"
    trap_button.disabled = game_state != GameState.PREPARATION or not economy.can_afford(SPIKE_TRAP_COST)
    defender_button.disabled = game_state != GameState.PREPARATION or not economy.can_afford(DEFENDER_COST)
    door_button.disabled = game_state != GameState.PREPARATION

func _refresh_build_ui() -> void:
    if not build_label or not trap_button or not defender_button:
        return
    var cost := SPIKE_TRAP_COST if build_mode == BuildMode.SPIKE_TRAP else DEFENDER_COST
    var mode_name := "Piège" if build_mode == BuildMode.SPIKE_TRAP else "Défenseur"
    build_label.text = "Mode : %s (%d or) | Pièges : %d | Défenseurs : %d" % [mode_name, cost, traps.size(), defenders.size()]
    trap_button.text = "Piège (%d or)" % SPIKE_TRAP_COST
    defender_button.text = "Défenseur (%d or)" % DEFENDER_COST

func _refresh_door_ui() -> void:
    if door_button:
        door_button.text = "Ouvrir porte" if door_closed else "Fermer (%d or)" % (0 if door_purchased else DOOR_COST)

func _draw_grid() -> void:
    for y in range(GRID_SIZE.y):
        for x in range(GRID_SIZE.x):
            var rect := Rect2(GRID_ORIGIN + Vector2(x, y) * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE))
            draw_rect(rect, Color("252a3a") if (x + y) % 2 == 0 else Color("212635"))
            draw_rect(rect, Color("3b4358"), false, 1.0)

func _draw_level_objects() -> void:
    for wall in walls:
        var rect := Rect2(_cell_top_left(wall) + Vector2(3, 3), Vector2(CELL_SIZE - 6, CELL_SIZE - 6))
        draw_rect(rect, Color("59627a"))
        draw_rect(rect, Color("78839e"), false, 2.0)
    draw_circle(_world_from_cell(ENTRANCE), 15.0, Color("4fd1a5"))
    _draw_collectible(TREASURE_TEXTURE, _world_from_cell(TREASURE))
    var door_rect := Rect2(_cell_top_left(DOOR) + Vector2(8, 2), Vector2(CELL_SIZE - 16, CELL_SIZE - 4))
    draw_rect(door_rect, Color("b64d55") if door_closed else Color("5fbf82"))
    draw_rect(door_rect, Color.WHITE, false, 2.0)

func _draw_traps() -> void:
    for cell: Vector2i in traps:
        var trap: SpikeTrap = traps[cell]
        var center := _world_from_cell(cell)
        var color := Color("ed6a5a") if trap.is_ready else Color("77515a")
        for offset in [-12.0, 0.0, 12.0]:
            draw_colored_polygon(PackedVector2Array([center + Vector2(offset - 5, 10), center + Vector2(offset, -12), center + Vector2(offset + 5, 10)]), color)

func _draw_defenders() -> void:
    for cell: Vector2i in defenders:
        var defender: Defender = defenders[cell]
        var center := _world_from_cell(cell)
        var tint := Color("c9a7ff") if defender.is_ready else Color("766484")
        var attack_remaining := float(defender_attack_flashes.get(cell, 0.0))
        var direction := adventurer_position - center
        center += CharacterAnimationRuntimeScript.attack_offset(attack_remaining, direction, 0.24, 8.0)
        _draw_character_frame(MonsterSprite, center, tint, not defender.is_ready, 1.0, 1.0, CharacterAnimationRuntimeScript.attack_scale(attack_remaining, 0.24))

func _draw_adventurer() -> void:
    if adventurer_health.is_dead:
        return
    var adventurer_id := waves.get_adventurer_data().id
    var texture: Texture2D = ADVENTURER_TEXTURES.get(adventurer_id, ADVENTURER_TEXTURES.champion)
    var moving := game_state == GameState.INVASION and path_index < path.size()
    var tint := CharacterAnimationRuntimeScript.damage_tint(adventurer_damage_flash)
    var draw_position := adventurer_position + CharacterAnimationRuntimeScript.attack_offset(adventurer_attack_flash, adventurer_attack_direction)
    var attack_scale := CharacterAnimationRuntimeScript.attack_scale(adventurer_attack_flash, 0.22)
    _draw_character_frame(texture, draw_position, tint, moving, adventurer_facing, _current_adventurer_speed_multiplier(), attack_scale)
    var bar_position := adventurer_position + Vector2(-18, -25)
    draw_rect(Rect2(bar_position, Vector2(36, 5)), Color("2a2d36"))
    draw_rect(Rect2(bar_position, Vector2(36.0 * adventurer_health.get_health_ratio(), 5)), Color("63d471"))

func _draw_character_frame(texture: Texture2D, center: Vector2, tint: Color = Color.WHITE, moving: bool = true, facing: float = 1.0, speed_multiplier: float = 1.0, scale_multiplier: float = 1.0, phase: float = 0.0) -> void:
    var frame := CharacterAnimationRuntimeScript.frame_index(character_animation_time, moving, speed_multiplier, phase)
    var source := Rect2(Vector2(frame * CHARACTER_FRAME_SIZE.x, 0), CHARACTER_FRAME_SIZE)
    var size := CHARACTER_DRAW_SIZE * scale_multiplier
    var destination := Rect2(center - size / 2.0, size)
    if facing < 0.0:
        destination.position.x += destination.size.x
        destination.size.x *= -1.0
    draw_texture_rect_region(texture, destination, source, tint)

func _draw_collectible(texture: Texture2D, center: Vector2, size: Vector2 = COLLECTIBLE_DRAW_SIZE) -> void:
    draw_texture_rect(texture, Rect2(center - size / 2.0, size), false)

func _on_adventurer_damaged(_amount: int, _current_health: int) -> void:
    adventurer_damage_flash = 0.28
    queue_redraw()

func _on_defender_attacked(cell: Vector2i, damage: int) -> void:
    run_stats.record_defender_attack(damage)
    status_label.text = "Le défenseur inflige %d dégâts." % damage
    defender_attack_flashes[cell] = 0.24
    _spawn_combat_effect(&"projectile", _world_from_cell(cell), adventurer_position, Color("b978ff"), 0.3)

func _tick_combat_presentation(delta: float) -> void:
    character_animation_time += delta
    adventurer_damage_flash = maxf(adventurer_damage_flash - delta, 0.0)
    adventurer_attack_flash = maxf(adventurer_attack_flash - delta, 0.0)
    for cell in defender_attack_flashes.keys():
        var remaining := maxf(float(defender_attack_flashes[cell]) - delta, 0.0)
        if remaining <= 0.0:
            defender_attack_flashes.erase(cell)
        else:
            defender_attack_flashes[cell] = remaining
    for index in range(combat_effects.size() - 1, -1, -1):
        combat_effects[index].remaining = maxf(float(combat_effects[index].remaining) - delta, 0.0)
        if float(combat_effects[index].remaining) <= 0.0:
            combat_effects.remove_at(index)

func _play_clash(monster_position: Vector2, effect_kind: StringName, color: Color) -> void:
    _spawn_combat_effect(effect_kind, monster_position, adventurer_position, color, 0.34)

func _play_adventurer_attack(target: Vector2, ranged: bool, empowered: bool = false) -> void:
    var direction := target - adventurer_position
    adventurer_attack_direction = direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
    adventurer_facing = CharacterAnimationRuntimeScript.facing_sign(direction.x, adventurer_facing)
    adventurer_attack_flash = 0.22
    var kind: StringName = &"projectile" if ranged else &"slash"
    var color := Color("fff36b") if empowered else (Color("78d8ff") if ranged else Color("fff0b8"))
    _spawn_combat_effect(kind, adventurer_position, target, color, 0.28 if ranged else 0.24)

func _spawn_combat_effect(kind: StringName, origin: Vector2, target: Vector2, color: Color, duration: float) -> void:
    combat_effects.append({
        "kind": kind,
        "origin": origin,
        "target": target,
        "color": color,
        "duration": duration,
        "remaining": duration,
    })
    if combat_effects.size() > 24:
        combat_effects.pop_front()

func _draw_combat_effects() -> void:
    for effect in combat_effects:
        var duration := maxf(float(effect.duration), 0.001)
        var progress := 1.0 - clampf(float(effect.remaining) / duration, 0.0, 1.0)
        var origin: Vector2 = effect.origin
        var target: Vector2 = effect.target
        var color: Color = effect.color
        match StringName(effect.kind):
            &"projectile", &"spectral", &"web":
                _draw_projectile_effect(origin, target, progress, color, StringName(effect.kind))
            &"splash":
                _draw_splash_effect(target, progress, color)
            _:
                _draw_slash_effect(origin, target, progress, color)

func _draw_projectile_effect(origin: Vector2, target: Vector2, progress: float, color: Color, kind: StringName) -> void:
    var eased := ease(clampf(progress, 0.0, 1.0), -1.5)
    var position := origin.lerp(target, eased)
    var trail_start := origin.lerp(target, maxf(eased - 0.18, 0.0))
    draw_line(trail_start, position, Color(color, 0.45), 4.0 if kind == &"web" else 3.0)
    if kind == &"web":
        draw_arc(position, 6.0, 0.0, TAU, 8, color, 2.0)
        draw_line(position - Vector2(5, 5), position + Vector2(5, 5), color, 1.0)
        draw_line(position + Vector2(-5, 5), position + Vector2(5, -5), color, 1.0)
    else:
        var radius := 7.0 if kind == &"spectral" else 5.0
        draw_circle(position, radius, Color(color, 0.35))
        draw_circle(position, radius * 0.5, color)
    if progress > 0.72:
        _draw_impact(target, (progress - 0.72) / 0.28, color)

func _draw_slash_effect(origin: Vector2, target: Vector2, progress: float, color: Color) -> void:
    var direction := target - origin
    var angle := direction.angle() if not direction.is_zero_approx() else 0.0
    var center := origin.lerp(target, 0.55)
    var alpha := sin(clampf(progress, 0.0, 1.0) * PI)
    draw_arc(center, 15.0 + progress * 7.0, angle - 0.9, angle + 0.9, 12, Color(color, alpha), 3.0)
    if progress > 0.55:
        _draw_impact(target, (progress - 0.55) / 0.45, color)

func _draw_splash_effect(target: Vector2, progress: float, color: Color) -> void:
    var alpha := 1.0 - progress
    draw_circle(target, 5.0 + progress * 19.0, Color(color, alpha * 0.25))
    draw_arc(target, 7.0 + progress * 17.0, 0.0, TAU, 18, Color(color, alpha), 2.0)
    for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]:
        var drop := target + direction.rotated(progress * 0.8) * (8.0 + progress * 15.0)
        draw_circle(drop, 3.0 * alpha, Color(color, alpha))

func _draw_impact(target: Vector2, progress: float, color: Color) -> void:
    var alpha := 1.0 - clampf(progress, 0.0, 1.0)
    for index in 8:
        var direction := Vector2.RIGHT.rotated(TAU * float(index) / 8.0)
        draw_line(target + direction * 5.0, target + direction * (10.0 + progress * 10.0), Color(color, alpha), 2.0)

func _world_from_cell(cell: Vector2i) -> Vector2:
    return GRID_ORIGIN + Vector2(cell) * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)

func _cell_top_left(cell: Vector2i) -> Vector2:
    return GRID_ORIGIN + Vector2(cell) * CELL_SIZE

func _cell_from_world(world_position: Vector2) -> Vector2i:
    var local := world_position - GRID_ORIGIN
    return Vector2i(floori(local.x / CELL_SIZE), floori(local.y / CELL_SIZE))

func _is_inside_grid(cell: Vector2i) -> bool:
    return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_SIZE.x and cell.y < GRID_SIZE.y

func _current_adventurer_speed_multiplier() -> float:
    var attack_brake := 0.2 if adventurer_attack_flash > 0.0 else 1.0
    return waves.get_speed_multiplier() * attack_brake

func _on_trap_placed() -> void:
    pass

func _configure_trap(_trap: SpikeTrap) -> void:
    pass

func _configure_defender(_defender: Defender) -> void:
    pass
