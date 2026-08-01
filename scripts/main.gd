extends Node2D

const HealthComponentScript := preload("res://scripts/components/health_component.gd")
const SpikeTrapScript := preload("res://scripts/traps/spike_trap.gd")
const GRID_SIZE := Vector2i(15, 10)
const CELL_SIZE := 48
const GRID_ORIGIN := Vector2(48, 96)
const ENTRANCE := Vector2i(0, 5)
const TREASURE := Vector2i(14, 5)
const DOOR := Vector2i(7, 5)
const MOVE_SPEED := 150.0
const PREPARATION_DURATION := 15.0
const ADVENTURER_MAX_HEALTH := 100

enum GameState { PREPARATION, INVASION, FINISHED }

var astar := AStarGrid2D.new()
var walls: Array[Vector2i] = []
var traps: Dictionary = {}
var door_closed := false
var adventurer_position := Vector2.ZERO
var path: Array[Vector2] = []
var path_index := 0
var game_state := GameState.PREPARATION
var preparation_time_left := PREPARATION_DURATION
var adventurer_health: HealthComponent
var status_label: Label
var phase_label: Label
var countdown_label: Label
var health_label: Label
var trap_label: Label
var door_button: Button
var start_button: Button

func _ready() -> void:
    _build_level()
    _configure_pathfinding()
    _build_health_component()
    _build_interface()
    _start_new_run()
    queue_redraw()

func _process(delta: float) -> void:
    for trap: SpikeTrap in traps.values():
        trap.tick(delta)

    if game_state == GameState.PREPARATION:
        preparation_time_left = maxf(preparation_time_left - delta, 0.0)
        _refresh_phase_ui()
        if preparation_time_left <= 0.0:
            _start_invasion()
        queue_redraw()
        return

    if game_state != GameState.INVASION or path_index >= path.size() or adventurer_health.is_dead:
        return

    var target := path[path_index]
    adventurer_position = adventurer_position.move_toward(target, MOVE_SPEED * delta)
    if adventurer_position.distance_to(target) < 1.0:
        adventurer_position = target
        _trigger_trap_at(_cell_from_world(adventurer_position))
        path_index += 1
        if path_index >= path.size() and not adventurer_health.is_dead:
            game_state = GameState.FINISHED
            status_label.text = "Le trésor a été pillé. Il faut améliorer les défenses."
            _refresh_phase_ui()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
        return
    var cell := _cell_from_world(event.position)
    if cell == DOOR:
        _toggle_door()
    elif game_state == GameState.PREPARATION:
        _place_spike_trap(cell)

func _draw() -> void:
    _draw_grid()
    _draw_level_objects()
    _draw_traps()
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
    for wall in walls:
        astar.set_point_solid(wall, true)

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

    phase_label = Label.new()
    phase_label.position = Vector2(48, 60)
    phase_label.add_theme_font_size_override("font_size", 18)
    add_child(phase_label)

    countdown_label = Label.new()
    countdown_label.position = Vector2(260, 60)
    countdown_label.add_theme_font_size_override("font_size", 18)
    add_child(countdown_label)

    status_label = Label.new()
    status_label.position = Vector2(48, 590)
    status_label.size = Vector2(650, 32)
    add_child(status_label)

    health_label = Label.new()
    health_label.position = Vector2(48, 620)
    health_label.size = Vector2(260, 30)
    add_child(health_label)

    trap_label = Label.new()
    trap_label.position = Vector2(320, 620)
    trap_label.size = Vector2(350, 30)
    add_child(trap_label)

    door_button = Button.new()
    door_button.position = Vector2(710, 574)
    door_button.size = Vector2(200, 42)
    door_button.pressed.connect(_toggle_door)
    add_child(door_button)

    start_button = Button.new()
    start_button.position = Vector2(710, 24)
    start_button.size = Vector2(200, 42)
    start_button.pressed.connect(_on_primary_button_pressed)
    add_child(start_button)
    _refresh_door_ui()

func _start_new_run() -> void:
    game_state = GameState.PREPARATION
    preparation_time_left = PREPARATION_DURATION
    adventurer_position = _world_from_cell(ENTRANCE)
    adventurer_health.reset()
    path.clear()
    path_index = 0
    for trap: SpikeTrap in traps.values():
        trap.queue_free()
    traps.clear()
    status_label.text = "Cliquez sur une case libre pour placer un piège à pointes."
    _refresh_phase_ui()
    _refresh_trap_ui()
    queue_redraw()

func _start_invasion() -> void:
    if game_state != GameState.PREPARATION:
        return
    game_state = GameState.INVASION
    _recalculate_path()
    _refresh_phase_ui()

func _on_primary_button_pressed() -> void:
    if game_state == GameState.PREPARATION:
        _start_invasion()
    else:
        _start_new_run()

func _place_spike_trap(cell: Vector2i) -> void:
    if not _is_valid_trap_cell(cell):
        status_label.text = "Placement impossible sur cette case."
        return
    var trap: SpikeTrap = SpikeTrapScript.new()
    trap.setup(cell)
    trap.triggered.connect(func(damage: int): status_label.text = "Piège déclenché : %d dégâts." % damage)
    add_child(trap)
    traps[cell] = trap
    status_label.text = "Piège placé. Vous pouvez en placer plusieurs avant l'invasion."
    _refresh_trap_ui()
    queue_redraw()

func _is_valid_trap_cell(cell: Vector2i) -> bool:
    return _is_inside_grid(cell) and cell != ENTRANCE and cell != TREASURE and cell != DOOR and not walls.has(cell) and not traps.has(cell)

func _trigger_trap_at(cell: Vector2i) -> void:
    if traps.has(cell):
        var trap: SpikeTrap = traps[cell]
        trap.try_trigger(adventurer_health)

func _toggle_door() -> void:
    if game_state == GameState.FINISHED:
        return
    door_closed = not door_closed
    astar.set_point_solid(DOOR, door_closed)
    _refresh_door_ui()
    if game_state == GameState.INVASION:
        _recalculate_path()
    queue_redraw()

func _on_adventurer_health_changed(current_health: int, max_health: int) -> void:
    if health_label:
        health_label.text = "Aventurier : %d / %d PV" % [current_health, max_health]
    queue_redraw()

func _on_adventurer_died() -> void:
    game_state = GameState.FINISHED
    path.clear()
    status_label.text = "L'aventurier a été éliminé. Le donjon est défendu !"
    _refresh_phase_ui()
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
        game_state = GameState.FINISHED
        status_label.text = "Chemin bloqué : le donjon est défendu."
    else:
        status_label.text = "L'aventurier cherche un chemin vers le trésor."
    _refresh_phase_ui()

func _refresh_phase_ui() -> void:
    match game_state:
        GameState.PREPARATION:
            phase_label.text = "Phase : PRÉPARATION"
            countdown_label.text = "Départ dans %d s" % ceili(preparation_time_left)
            start_button.text = "Lancer l'invasion"
        GameState.INVASION:
            phase_label.text = "Phase : INVASION"
            countdown_label.text = ""
            start_button.text = "Relancer la partie"
        GameState.FINISHED:
            phase_label.text = "Phase : TERMINÉE"
            countdown_label.text = ""
            start_button.text = "Nouvelle partie"

func _refresh_trap_ui() -> void:
    trap_label.text = "Pièges placés : %d" % traps.size()

func _refresh_door_ui() -> void:
    door_button.text = "Ouvrir la porte" if door_closed else "Fermer la porte"

func _draw_grid() -> void:
    for y in range(GRID_SIZE.y):
        for x in range(GRID_SIZE.x):
            var rect := Rect2(GRID_ORIGIN + Vector2(x, y) * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE))
            var fill := Color("252a3a") if (x + y) % 2 == 0 else Color("212635")
            draw_rect(rect, fill)
            draw_rect(rect, Color("3b4358"), false, 1.0)

func _draw_level_objects() -> void:
    for wall in walls:
        var rect := Rect2(_cell_top_left(wall) + Vector2(3, 3), Vector2(CELL_SIZE - 6, CELL_SIZE - 6))
        draw_rect(rect, Color("59627a"))
        draw_rect(rect, Color("78839e"), false, 2.0)
    var entrance_center := _world_from_cell(ENTRANCE)
    draw_circle(entrance_center, 15.0, Color("4fd1a5"))
    var treasure_center := _world_from_cell(TREASURE)
    draw_circle(treasure_center, 17.0, Color("f5c451"))
    draw_circle(treasure_center, 8.0, Color("fff0a6"))
    var door_rect := Rect2(_cell_top_left(DOOR) + Vector2(8, 2), Vector2(CELL_SIZE - 16, CELL_SIZE - 4))
    draw_rect(door_rect, Color("b64d55") if door_closed else Color("5fbf82"))
    draw_rect(door_rect, Color.WHITE, false, 2.0)

func _draw_traps() -> void:
    for cell: Vector2i in traps:
        var trap: SpikeTrap = traps[cell]
        var center := _world_from_cell(cell)
        var color := Color("ed6a5a") if trap.is_ready else Color("77515a")
        for offset in [-12.0, 0.0, 12.0]:
            var points := PackedVector2Array([center + Vector2(offset - 5, 10), center + Vector2(offset, -12), center + Vector2(offset + 5, 10)])
            draw_colored_polygon(points, color)

func _draw_adventurer() -> void:
    if adventurer_health.is_dead:
        return
    draw_circle(adventurer_position, 14.0, Color("62a7ff"))
    draw_circle(adventurer_position + Vector2(-5, -4), 2.0, Color.WHITE)
    draw_circle(adventurer_position + Vector2(5, -4), 2.0, Color.WHITE)
    var bar_position := adventurer_position + Vector2(-18, -25)
    draw_rect(Rect2(bar_position, Vector2(36, 5)), Color("2a2d36"))
    draw_rect(Rect2(bar_position, Vector2(36.0 * adventurer_health.get_health_ratio(), 5)), Color("63d471"))

func _world_from_cell(cell: Vector2i) -> Vector2:
    return GRID_ORIGIN + Vector2(cell) * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)

func _cell_top_left(cell: Vector2i) -> Vector2:
    return GRID_ORIGIN + Vector2(cell) * CELL_SIZE

func _cell_from_world(world_position: Vector2) -> Vector2i:
    var local := world_position - GRID_ORIGIN
    return Vector2i(floori(local.x / CELL_SIZE), floori(local.y / CELL_SIZE))

func _is_inside_grid(cell: Vector2i) -> bool:
    return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_SIZE.x and cell.y < GRID_SIZE.y
