extends Node2D

const GRID_SIZE := Vector2i(15, 10)
const CELL_SIZE := 48
const GRID_ORIGIN := Vector2(48, 96)
const ENTRANCE := Vector2i(0, 5)
const TREASURE := Vector2i(14, 5)
const DOOR := Vector2i(7, 5)
const MOVE_SPEED := 150.0

var astar := AStarGrid2D.new()
var walls: Array[Vector2i] = []
var door_closed := false
var adventurer_position := Vector2.ZERO
var path: Array[Vector2] = []
var path_index := 0
var run_finished := false
var status_label: Label
var door_button: Button

func _ready() -> void:
    _build_level()
    _configure_pathfinding()
    _build_interface()
    _restart_invasion()
    queue_redraw()

func _process(delta: float) -> void:
    if run_finished or path_index >= path.size():
        return

    var target := path[path_index]
    adventurer_position = adventurer_position.move_toward(target, MOVE_SPEED * delta)

    if adventurer_position.distance_to(target) < 1.0:
        adventurer_position = target
        path_index += 1
        if path_index >= path.size():
            run_finished = true
            status_label.text = "Le trésor a été pillé. Il faut ajouter des défenses !"

    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if _cell_from_world(event.position) == DOOR:
            _toggle_door()

func _draw() -> void:
    _draw_grid()
    _draw_level_objects()
    _draw_adventurer()

func _build_level() -> void:
    for x in range(2, 13):
        if x != DOOR.x:
            walls.append(Vector2i(x, 4))
            walls.append(Vector2i(x, 6))

    walls.append_array([
        Vector2i(5, 1), Vector2i(5, 2), Vector2i(5, 3),
        Vector2i(9, 7), Vector2i(9, 8),
        Vector2i(11, 2), Vector2i(12, 2), Vector2i(13, 2)
    ])

func _configure_pathfinding() -> void:
    astar.region = Rect2i(Vector2i.ZERO, GRID_SIZE)
    astar.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
    astar.offset = Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
    astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
    astar.update()

    for wall in walls:
        astar.set_point_solid(wall, true)

func _build_interface() -> void:
    var title := Label.new()
    title.text = "DUNGEON ARCHITECT — Prototype"
    title.position = Vector2(48, 24)
    title.add_theme_font_size_override("font_size", 26)
    add_child(title)

    status_label = Label.new()
    status_label.position = Vector2(48, 590)
    status_label.size = Vector2(580, 32)
    add_child(status_label)

    door_button = Button.new()
    door_button.position = Vector2(710, 574)
    door_button.size = Vector2(200, 42)
    door_button.pressed.connect(_toggle_door)
    add_child(door_button)

    var restart_button := Button.new()
    restart_button.text = "Relancer l'invasion"
    restart_button.position = Vector2(710, 24)
    restart_button.size = Vector2(200, 42)
    restart_button.pressed.connect(_restart_invasion)
    add_child(restart_button)

    _refresh_door_ui()

func _restart_invasion() -> void:
    adventurer_position = _world_from_cell(ENTRANCE)
    run_finished = false
    _recalculate_path()

func _toggle_door() -> void:
    door_closed = not door_closed
    astar.set_point_solid(DOOR, door_closed)
    _refresh_door_ui()
    _recalculate_path()
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
        run_finished = true
        status_label.text = "Chemin bloqué : le donjon est défendu."
    else:
        run_finished = false
        status_label.text = "L'aventurier cherche un chemin vers le trésor."

func _refresh_door_ui() -> void:
    door_button.text = "Ouvrir la porte" if door_closed else "Fermer la porte"

func _draw_grid() -> void:
    for y in range(GRID_SIZE.y):
        for x in range(GRID_SIZE.x):
            var cell := Vector2i(x, y)
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
    draw_string(ThemeDB.fallback_font, entrance_center + Vector2(-18, -24), "ENTRÉE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

    var treasure_center := _world_from_cell(TREASURE)
    draw_circle(treasure_center, 17.0, Color("f5c451"))
    draw_circle(treasure_center, 8.0, Color("fff0a6"))
    draw_string(ThemeDB.fallback_font, treasure_center + Vector2(-24, -24), "TRÉSOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

    var door_rect := Rect2(_cell_top_left(DOOR) + Vector2(8, 2), Vector2(CELL_SIZE - 16, CELL_SIZE - 4))
    draw_rect(door_rect, Color("b64d55") if door_closed else Color("5fbf82"))
    draw_rect(door_rect, Color.WHITE, false, 2.0)

func _draw_adventurer() -> void:
    draw_circle(adventurer_position, 14.0, Color("62a7ff"))
    draw_circle(adventurer_position + Vector2(-5, -4), 2.0, Color.WHITE)
    draw_circle(adventurer_position + Vector2(5, -4), 2.0, Color.WHITE)

func _world_from_cell(cell: Vector2i) -> Vector2:
    return GRID_ORIGIN + Vector2(cell) * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)

func _cell_top_left(cell: Vector2i) -> Vector2:
    return GRID_ORIGIN + Vector2(cell) * CELL_SIZE

func _cell_from_world(world_position: Vector2) -> Vector2i:
    var local := world_position - GRID_ORIGIN
    return Vector2i(floori(local.x / CELL_SIZE), floori(local.y / CELL_SIZE))

func _is_inside_grid(cell: Vector2i) -> bool:
    return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_SIZE.x and cell.y < GRID_SIZE.y
