extends GameController

const DungeonBuildRuntimeScript := preload("res://scripts/build/dungeon_build_runtime.gd")

enum ConstructionMode { DEFENCES, PLACE_WALL, REMOVE_WALL }

var dungeon_build: DungeonBuildRuntime = DungeonBuildRuntimeScript.new()
var construction_mode := ConstructionMode.DEFENCES
var base_walls: Array[Vector2i] = []
var wall_button: Button
var remove_wall_button: Button
var passage_cooldowns: Dictionary = {}
var adventurer_passage_cooldown := 0.0

func _build_level() -> void:
    super._build_level()
    base_walls = walls.duplicate()
    dungeon_build.configure(
        GRID_SIZE,
        8,
        base_walls,
        ENTRANCE,
        TREASURE,
        _construction_reserved_cells()
    )
    dungeon_build.configure_default_passages()

func _build_interface() -> void:
    super._build_interface()
    wall_button = shortcut_buttons.get(8) as Button
    remove_wall_button = shortcut_buttons.get(9) as Button

func _start_new_campaign() -> void:
    if not base_walls.is_empty():
        walls.assign(base_walls)
        dungeon_build.configure(
            GRID_SIZE,
            8,
            base_walls,
            ENTRANCE,
            TREASURE,
            _construction_reserved_cells()
        )
        dungeon_build.configure_default_passages()
        if astar.region.size != Vector2i.ZERO:
            _synchronize_wall_pathfinding()
    construction_mode = ConstructionMode.DEFENCES
    adventurer_passage_cooldown = 0.0
    super._start_new_campaign()

func _process(delta: float) -> void:
    super._process(delta)
    adventurer_passage_cooldown = maxf(adventurer_passage_cooldown - delta, 0.0)
    if game_state != GameState.INVASION or adventurer_passage_cooldown > 0.0:
        return
    var cell := _cell_from_world(adventurer_position)
    var destination := dungeon_build.resolve_adventurer_passage(cell)
    if destination == cell:
        return
    adventurer_position = GRID_ORIGIN + Vector2(destination) * CELL_SIZE + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
    adventurer_passage_cooldown = 1.0
    _recalculate_path()
    status_label.text = "L'équipe emprunte un tunnel vers %s." % destination

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_W:
            _set_construction_mode(ConstructionMode.PLACE_WALL)
            return
        if event.keycode == KEY_R:
            _set_construction_mode(ConstructionMode.REMOVE_WALL)
            return
    if construction_mode == ConstructionMode.DEFENCES or game_state != GameState.PREPARATION:
        super._unhandled_input(event)
        return
    if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
        return

    var cell := _cell_from_world(event.position)
    if construction_mode == ConstructionMode.PLACE_WALL:
        _try_place_wall(cell)
    else:
        _try_remove_wall(cell)

func _try_place_wall(cell: Vector2i) -> void:
    var result := dungeon_build.place_wall(cell)
    if not bool(result.get("ok", false)):
        status_label.text = "Mur impossible : %s." % result.get("reason", "position invalide")
        return
    walls.assign(result.get("walls", []))
    gold = int(result.get("budget", gold))
    _synchronize_wall_pathfinding()
    _refresh_ui()

func _try_remove_wall(cell: Vector2i) -> void:
    var result := dungeon_build.remove_wall(cell)
    if not bool(result.get("ok", false)):
        status_label.text = "Retrait impossible : %s." % result.get("reason", "position invalide")
        return
    walls.assign(result.get("walls", []))
    gold = int(result.get("budget", gold))
    _synchronize_wall_pathfinding()
    _refresh_ui()

func _set_construction_mode(mode: ConstructionMode) -> void:
    construction_mode = mode
    if wall_button:
        wall_button.button_pressed = mode == ConstructionMode.PLACE_WALL
    if remove_wall_button:
        remove_wall_button.button_pressed = mode == ConstructionMode.REMOVE_WALL

func _synchronize_wall_pathfinding() -> void:
    _rebuild_astar()
    _recalculate_path()
    queue_redraw()

func _construction_reserved_cells() -> Array[Vector2i]:
    var reserved: Array[Vector2i] = [ENTRANCE, TREASURE]
    reserved.append_array(room_cells)
    reserved.append_array(defenses.keys())
    return reserved
