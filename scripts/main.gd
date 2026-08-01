extends Node2D

const HealthComponentScript := preload("res://scripts/components/health_component.gd")
const SpikeTrapScript := preload("res://scripts/traps/spike_trap.gd")
const DefenderScript := preload("res://scripts/monsters/defender.gd")
const RunStatsScript := preload("res://scripts/core/run_stats.gd")
const EconomyScript := preload("res://scripts/core/economy.gd")
const GRID_SIZE := Vector2i(15, 10)
const CELL_SIZE := 48
const GRID_ORIGIN := Vector2(48, 96)
const ENTRANCE := Vector2i(0, 5)
const TREASURE := Vector2i(14, 5)
const DOOR := Vector2i(7, 5)
const MOVE_SPEED := 150.0
const PREPARATION_DURATION := 15.0
const ADVENTURER_MAX_HEALTH := 100
const STARTING_GOLD := 100
const SPIKE_TRAP_COST := 25
const DEFENDER_COST := 40
const DOOR_COST := 10
const KILL_REWARD := 30

enum GameState { PREPARATION, INVASION, FINISHED }
enum BuildMode { SPIKE_TRAP, DEFENDER }

var astar := AStarGrid2D.new()
var walls: Array[Vector2i] = []
var traps: Dictionary = {}
var defenders: Dictionary = {}
var build_mode := BuildMode.SPIKE_TRAP
var door_closed := false
var door_purchased := false
var adventurer_position := Vector2.ZERO
var path: Array[Vector2] = []
var path_index := 0
var game_state := GameState.PREPARATION
var preparation_time_left := PREPARATION_DURATION
var adventurer_health: HealthComponent
var run_stats: RunStats = RunStatsScript.new()
var economy: Economy = EconomyScript.new()
var status_label: Label
var phase_label: Label
var countdown_label: Label
var health_label: Label
var build_label: Label
var gold_label: Label
var door_button: Button
var start_button: Button
var trap_button: Button
var defender_button: Button
var result_panel: Panel
var result_title: Label
var result_summary: Label

func _ready() -> void:
    _build_level()
    _configure_pathfinding()
    _build_health_component()
    _build_interface()
    economy.starting_gold = STARTING_GOLD
    economy.gold_changed.connect(_on_gold_changed)
    _start_new_run()
    queue_redraw()

func _process(delta: float) -> void:
    for trap: SpikeTrap in traps.values(): trap.tick(delta)
    for defender: Defender in defenders.values():
        defender.tick(delta)
        if game_state == GameState.INVASION and not adventurer_health.is_dead:
            defender.try_attack(adventurer_position, adventurer_health, CELL_SIZE)
    if game_state == GameState.PREPARATION:
        preparation_time_left = maxf(preparation_time_left - delta, 0.0)
        _refresh_phase_ui()
        if preparation_time_left <= 0.0: _start_invasion()
        queue_redraw()
        return
    if game_state != GameState.INVASION or adventurer_health.is_dead: return
    run_stats.tick(delta)
    if path_index >= path.size(): return
    var target := path[path_index]
    adventurer_position = adventurer_position.move_toward(target, MOVE_SPEED * delta)
    if adventurer_position.distance_to(target) < 1.0:
        adventurer_position = target
        _trigger_trap_at(_cell_from_world(adventurer_position))
        path_index += 1
        if path_index >= path.size() and not adventurer_health.is_dead:
            _finish_run(false, "Le trésor a été pillé.")
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed): return
    var cell := _cell_from_world(event.position)
    if cell == DOOR: _toggle_door()
    elif game_state == GameState.PREPARATION:
        if build_mode == BuildMode.SPIKE_TRAP: _place_spike_trap(cell)
        else: _place_defender(cell)

func _draw() -> void:
    _draw_grid()
    _draw_level_objects()
    _draw_traps()
    _draw_defenders()
    _draw_adventurer()

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
    for wall in walls: astar.set_point_solid(wall, true)

func _build_health_component() -> void:
    adventurer_health = HealthComponentScript.new()
    adventurer_health.max_health = ADVENTURER_MAX_HEALTH
    adventurer_health.health_changed.connect(_on_adventurer_health_changed)
    adventurer_health.died.connect(_on_adventurer_died)
    add_child(adventurer_health)

func _build_interface() -> void:
    var title := Label.new()
    title.text = "DUNGEON ARCHITECT — Prototype"
    title.position = Vector2(48, 24)
    title.add_theme_font_size_override("font_size", 26)
    add_child(title)
    phase_label = Label.new(); phase_label.position = Vector2(48, 60); phase_label.add_theme_font_size_override("font_size", 18); add_child(phase_label)
    countdown_label = Label.new(); countdown_label.position = Vector2(260, 60); countdown_label.add_theme_font_size_override("font_size", 18); add_child(countdown_label)
    gold_label = Label.new(); gold_label.position = Vector2(470, 60); gold_label.add_theme_font_size_override("font_size", 18); add_child(gold_label)
    status_label = Label.new(); status_label.position = Vector2(48, 590); status_label.size = Vector2(650, 32); add_child(status_label)
    health_label = Label.new(); health_label.position = Vector2(48, 620); health_label.size = Vector2(260, 30); add_child(health_label)
    build_label = Label.new(); build_label.position = Vector2(320, 620); build_label.size = Vector2(500, 30); add_child(build_label)
    trap_button = Button.new(); trap_button.position = Vector2(470, 574); trap_button.size = Vector2(165, 42); trap_button.pressed.connect(func(): _set_build_mode(BuildMode.SPIKE_TRAP)); add_child(trap_button)
    defender_button = Button.new(); defender_button.position = Vector2(640, 574); defender_button.size = Vector2(135, 42); defender_button.pressed.connect(func(): _set_build_mode(BuildMode.DEFENDER)); add_child(defender_button)
    door_button = Button.new(); door_button.position = Vector2(780, 574); door_button.size = Vector2(150, 42); door_button.pressed.connect(_toggle_door); add_child(door_button)
    start_button = Button.new(); start_button.position = Vector2(710, 24); start_button.size = Vector2(200, 42); start_button.pressed.connect(_on_primary_button_pressed); add_child(start_button)
    result_panel = Panel.new(); result_panel.position = Vector2(290, 205); result_panel.size = Vector2(440, 250); result_panel.visible = false; add_child(result_panel)
    result_title = Label.new(); result_title.position = Vector2(30, 24); result_title.size = Vector2(380, 45); result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; result_title.add_theme_font_size_override("font_size", 30); result_panel.add_child(result_title)
    result_summary = Label.new(); result_summary.position = Vector2(55, 85); result_summary.size = Vector2(330, 130); result_summary.add_theme_font_size_override("font_size", 18); result_panel.add_child(result_summary)

func _start_new_run() -> void:
    game_state = GameState.PREPARATION
    preparation_time_left = PREPARATION_DURATION
    adventurer_position = _world_from_cell(ENTRANCE)
    adventurer_health.reset()
    run_stats.reset()
    economy.reset()
    path.clear(); path_index = 0; result_panel.visible = false
    for trap: SpikeTrap in traps.values(): trap.queue_free()
    for defender: Defender in defenders.values(): defender.queue_free()
    traps.clear(); defenders.clear(); build_mode = BuildMode.SPIKE_TRAP
    door_closed = false; door_purchased = false; astar.set_point_solid(DOOR, false)
    status_label.text = "Choisissez une défense puis cliquez sur une case libre."
    _refresh_phase_ui(); _refresh_build_ui(); _refresh_door_ui(); queue_redraw()

func _start_invasion() -> void:
    if game_state != GameState.PREPARATION: return
    game_state = GameState.INVASION
    _recalculate_path(); _refresh_phase_ui()

func _on_primary_button_pressed() -> void:
    if game_state == GameState.PREPARATION: _start_invasion()
    else: _start_new_run()

func _set_build_mode(mode: BuildMode) -> void:
    if game_state != GameState.PREPARATION: return
    build_mode = mode
    status_label.text = "Mode de construction modifié."
    _refresh_build_ui()

func _place_spike_trap(cell: Vector2i) -> void:
    if not _is_valid_build_cell(cell): status_label.text = "Placement impossible sur cette case."; return
    if not economy.spend(SPIKE_TRAP_COST): status_label.text = "Or insuffisant pour ce piège."; return
    var trap: SpikeTrap = SpikeTrapScript.new()
    trap.setup(cell)
    trap.triggered.connect(func(damage: int): run_stats.record_trap(damage); status_label.text = "Piège déclenché : %d dégâts." % damage)
    add_child(trap); traps[cell] = trap
    status_label.text = "Piège placé pour %d or." % SPIKE_TRAP_COST
    _refresh_build_ui(); queue_redraw()

func _place_defender(cell: Vector2i) -> void:
    if not _is_valid_build_cell(cell): status_label.text = "Placement impossible sur cette case."; return
    if not economy.spend(DEFENDER_COST): status_label.text = "Or insuffisant pour ce défenseur."; return
    var defender: Defender = DefenderScript.new()
    defender.setup(cell, _world_from_cell(cell))
    defender.attacked.connect(func(damage: int): run_stats.record_defender_attack(damage); status_label.text = "Le défenseur inflige %d dégâts." % damage)
    add_child(defender); defenders[cell] = defender
    status_label.text = "Défenseur placé pour %d or." % DEFENDER_COST
    _refresh_build_ui(); queue_redraw()

func _is_valid_build_cell(cell: Vector2i) -> bool:
    return _is_inside_grid(cell) and cell != ENTRANCE and cell != TREASURE and cell != DOOR and not walls.has(cell) and not traps.has(cell) and not defenders.has(cell)

func _trigger_trap_at(cell: Vector2i) -> void:
    if traps.has(cell): (traps[cell] as SpikeTrap).try_trigger(adventurer_health)

func _toggle_door() -> void:
    if game_state == GameState.FINISHED: return
    if not door_closed and not door_purchased:
        if not economy.spend(DOOR_COST): status_label.text = "Or insuffisant pour verrouiller la porte."; return
        door_purchased = true
    door_closed = not door_closed
    astar.set_point_solid(DOOR, door_closed)
    status_label.text = "Porte verrouillée pour %d or." % DOOR_COST if door_closed and door_purchased else "Porte ouverte."
    _refresh_door_ui(); _refresh_build_ui()
    if game_state == GameState.INVASION: _recalculate_path()
    queue_redraw()

func _on_gold_changed(current_gold: int) -> void:
    if gold_label: gold_label.text = "Or : %d" % current_gold
    _refresh_build_ui()

func _on_adventurer_health_changed(current_health: int, max_health: int) -> void:
    if health_label: health_label.text = "Aventurier : %d / %d PV" % [current_health, max_health]
    queue_redraw()

func _on_adventurer_died() -> void:
    economy.add_gold(KILL_REWARD)
    _finish_run(true, "L'aventurier a été éliminé. Récompense : +%d or." % KILL_REWARD)

func _finish_run(victory: bool, message: String) -> void:
    if game_state == GameState.FINISHED: return
    game_state = GameState.FINISHED; path.clear(); run_stats.finish("VICTOIRE" if victory else "DÉFAITE")
    status_label.text = message
    result_title.text = run_stats.result
    result_title.modulate = Color("63d471") if victory else Color("ed6a5a")
    result_summary.text = run_stats.summary() + "\nOr restant : %d" % economy.current_gold
    result_panel.visible = true
    _refresh_phase_ui(); queue_redraw()

func _recalculate_path() -> void:
    var start_cell := _cell_from_world(adventurer_position)
    if not _is_inside_grid(start_cell): start_cell = ENTRANCE
    var cell_path := astar.get_id_path(start_cell, TREASURE)
    path.clear(); path_index = 0
    for cell in cell_path: path.append(_world_from_cell(cell))
    if path.size() > 1: path.remove_at(0)
    if path.is_empty(): _finish_run(true, "Chemin bloqué : le donjon est défendu.")
    else: status_label.text = "L'aventurier cherche un chemin vers le trésor."
    _refresh_phase_ui()

func _refresh_phase_ui() -> void:
    match game_state:
        GameState.PREPARATION:
            phase_label.text = "Phase : PRÉPARATION"; countdown_label.text = "Départ dans %d s" % ceili(preparation_time_left); start_button.text = "Lancer l'invasion"
        GameState.INVASION:
            phase_label.text = "Phase : INVASION"; countdown_label.text = ""; start_button.text = "Recommencer"
        GameState.FINISHED:
            phase_label.text = "Phase : TERMINÉE"; countdown_label.text = ""; start_button.text = "Rejouer"
    trap_button.disabled = game_state != GameState.PREPARATION or not economy.can_afford(SPIKE_TRAP_COST)
    defender_button.disabled = game_state != GameState.PREPARATION or not economy.can_afford(DEFENDER_COST)

func _refresh_build_ui() -> void:
    if not build_label or not trap_button or not defender_button: return
    var cost := SPIKE_TRAP_COST if build_mode == BuildMode.SPIKE_TRAP else DEFENDER_COST
    var mode_name := "Piège" if build_mode == BuildMode.SPIKE_TRAP else "Défenseur"
    build_label.text = "Mode : %s (%d or) | Pièges : %d | Défenseurs : %d" % [mode_name, cost, traps.size(), defenders.size()]
    trap_button.text = "Piège (%d or)" % SPIKE_TRAP_COST
    defender_button.text = "Défenseur (%d or)" % DEFENDER_COST
    _refresh_phase_ui()

func _refresh_door_ui() -> void:
    if door_button: door_button.text = "Ouvrir porte" if door_closed else "Fermer (%d or)" % (0 if door_purchased else DOOR_COST)

func _draw_grid() -> void:
    for y in range(GRID_SIZE.y):
        for x in range(GRID_SIZE.x):
            var rect := Rect2(GRID_ORIGIN + Vector2(x, y) * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE))
            draw_rect(rect, Color("252a3a") if (x + y) % 2 == 0 else Color("212635")); draw_rect(rect, Color("3b4358"), false, 1.0)

func _draw_level_objects() -> void:
    for wall in walls:
        var rect := Rect2(_cell_top_left(wall) + Vector2(3, 3), Vector2(CELL_SIZE - 6, CELL_SIZE - 6))
        draw_rect(rect, Color("59627a")); draw_rect(rect, Color("78839e"), false, 2.0)
    draw_circle(_world_from_cell(ENTRANCE), 15.0, Color("4fd1a5"))
    var treasure_center := _world_from_cell(TREASURE)
    draw_circle(treasure_center, 17.0, Color("f5c451")); draw_circle(treasure_center, 8.0, Color("fff0a6"))
    var door_rect := Rect2(_cell_top_left(DOOR) + Vector2(8, 2), Vector2(CELL_SIZE - 16, CELL_SIZE - 4))
    draw_rect(door_rect, Color("b64d55") if door_closed else Color("5fbf82")); draw_rect(door_rect, Color.WHITE, false, 2.0)

func _draw_traps() -> void:
    for cell: Vector2i in traps:
        var trap: SpikeTrap = traps[cell]; var center := _world_from_cell(cell); var color := Color("ed6a5a") if trap.is_ready else Color("77515a")
        for offset in [-12.0, 0.0, 12.0]: draw_colored_polygon(PackedVector2Array([center + Vector2(offset - 5, 10), center + Vector2(offset, -12), center + Vector2(offset + 5, 10)]), color)

func _draw_defenders() -> void:
    for cell: Vector2i in defenders:
        var defender: Defender = defenders[cell]; var center := _world_from_cell(cell)
        draw_circle(center, 15.0, Color("9b5de5") if defender.is_ready else Color("5e4778")); draw_circle(center + Vector2(-5, -4), 2.0, Color.WHITE); draw_circle(center + Vector2(5, -4), 2.0, Color.WHITE)

func _draw_adventurer() -> void:
    if adventurer_health.is_dead: return
    draw_circle(adventurer_position, 14.0, Color("62a7ff")); draw_circle(adventurer_position + Vector2(-5, -4), 2.0, Color.WHITE); draw_circle(adventurer_position + Vector2(5, -4), 2.0, Color.WHITE)
    var bar_position := adventurer_position + Vector2(-18, -25)
    draw_rect(Rect2(bar_position, Vector2(36, 5)), Color("2a2d36")); draw_rect(Rect2(bar_position, Vector2(36.0 * adventurer_health.get_health_ratio(), 5)), Color("63d471"))

func _world_from_cell(cell: Vector2i) -> Vector2: return GRID_ORIGIN + Vector2(cell) * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
func _cell_top_left(cell: Vector2i) -> Vector2: return GRID_ORIGIN + Vector2(cell) * CELL_SIZE
func _cell_from_world(world_position: Vector2) -> Vector2i:
    var local := world_position - GRID_ORIGIN
    return Vector2i(floori(local.x / CELL_SIZE), floori(local.y / CELL_SIZE))
func _is_inside_grid(cell: Vector2i) -> bool: return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_SIZE.x and cell.y < GRID_SIZE.y
