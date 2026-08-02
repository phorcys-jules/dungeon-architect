extends "res://scripts/game_controller.gd"

const DungeonBuildRuntimeScript := preload("res://scripts/build/dungeon_build_runtime.gd")

enum ConstructionMode { DEFENCES, PLACE_WALL, REMOVE_WALL }

var dungeon_build: DungeonBuildRuntime = DungeonBuildRuntimeScript.new()
var construction_mode := ConstructionMode.DEFENCES
var base_walls: Array[Vector2i] = []
var wall_button: Button
var remove_wall_button: Button
var passage_cooldowns: Dictionary = {}

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

    wall_button = Button.new()
    wall_button.text = "Placer un mur"
    wall_button.position = Vector2(48, 665)
    wall_button.size = Vector2(155, 38)
    wall_button.pressed.connect(func(): _set_construction_mode(ConstructionMode.PLACE_WALL))
    add_child(wall_button)

    remove_wall_button = Button.new()
    remove_wall_button.text = "Retirer un mur"
    remove_wall_button.position = Vector2(210, 665)
    remove_wall_button.size = Vector2(155, 38)
    remove_wall_button.pressed.connect(func(): _set_construction_mode(ConstructionMode.REMOVE_WALL))
    add_child(remove_wall_button)

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
    super._start_new_campaign()

func _unhandled_input(event: InputEvent) -> void:
    if construction_mode == ConstructionMode.DEFENCES or game_state != GameState.PREPARATION:
        super._unhandled_input(event)
        return
    if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
        return

    var cell := _cell_from_world(event.position)
    if construction_mode == ConstructionMode.PLACE_WALL:
        _try_place_free_wall(cell)
    elif construction_mode == ConstructionMode.REMOVE_WALL:
        _try_remove_free_wall(cell)

func _set_build_mode(mode: BuildMode) -> void:
    construction_mode = ConstructionMode.DEFENCES
    super._set_build_mode(mode)

func _set_construction_mode(mode: ConstructionMode) -> void:
    if game_state != GameState.PREPARATION:
        return
    construction_mode = mode
    status_label.text = "Cliquez sur une case libre pour placer un mur." if mode == ConstructionMode.PLACE_WALL else "Cliquez sur un mur construit pour le retirer."
    _refresh_build_ui()

func _try_place_free_wall(cell: Vector2i) -> void:
    if not _is_valid_build_cell(cell):
        status_label.text = "Cette case ne peut pas recevoir de mur."
        return
    var result := dungeon_build.try_place_wall(cell, economy.current_gold)
    if not result.ok:
        status_label.text = "Mur refusé : budget, or ou chemin invalide."
        return
    economy.spend(-int(result.gold_delta))
    walls.append(cell)
    astar.set_point_solid(cell, true)
    _recalculate_path()
    status_label.text = "Mur placé. Budget restant : %d." % dungeon_build.remaining_wall_budget()
    _refresh_build_ui()
    queue_redraw()

func _try_remove_free_wall(cell: Vector2i) -> void:
    var result := dungeon_build.try_remove_wall(cell)
    if not result.ok:
        status_label.text = "Seuls les murs construits pendant la run peuvent être retirés."
        return
    walls.erase(cell)
    astar.set_point_solid(cell, false)
    economy.add_gold(int(result.gold_delta))
    _recalculate_path()
    status_label.text = "Mur retiré : +%d or." % int(result.gold_delta)
    _refresh_build_ui()
    queue_redraw()

func _synchronize_wall_pathfinding() -> void:
    for x in GRID_SIZE.x:
        for y in GRID_SIZE.y:
            astar.set_point_solid(Vector2i(x, y), false)
    for cell in dungeon_build.blocked_cells():
        astar.set_point_solid(cell, true)
    astar.set_point_solid(DOOR, door_closed)

func _update_mobile_monsters(delta: float, adventurer_cell: Vector2i) -> void:
    var occupied: Array[Vector2i] = []
    for monster in mobile_monsters:
        occupied.append(monster.cell)

    var blocked: Array[Vector2i] = walls.duplicate()
    if door_closed:
        blocked.append(DOOR)
    var targets := monster_ai.assign_targets(occupied, monster_behaviours, adventurer_cell, adventurer_direction, TREASURE, active_route_target, blocked)

    for index in mobile_monsters.size():
        passage_cooldowns[index] = maxf(float(passage_cooldowns.get(index, 0.0)) - delta, 0.0)
        var monster := mobile_monsters[index]
        if not monster.has_path():
            var target := monster.home_cell if loop_rules.is_panicking() else targets[index]
            target.x = clampi(target.x, 0, GRID_SIZE.x - 1)
            target.y = clampi(target.y, 0, GRID_SIZE.y - 1)
            if walls.has(target):
                target = adventurer_cell
            var cells: Array[Vector2i] = []
            for point in astar.get_id_path(monster.cell, target):
                var point_cell := Vector2i(point)
                if point_cell != monster.cell and not occupied.has(point_cell):
                    cells.append(point_cell)
            monster.set_path(cells)

        monster.tick_grid(delta, CELL_SIZE)
        var monster_cell := monster.cell
        if float(passage_cooldowns[index]) <= 0.0:
            var passage_destination := dungeon_build.resolve_monster_passage(monster_cell, _monster_passage_tags(index))
            if passage_destination != monster_cell:
                monster.cell = passage_destination
                monster.world_position = Vector2(passage_destination) * CELL_SIZE
                monster.path.clear()
                monster.path_index = 0
                monster_cell = passage_destination
                passage_cooldowns[index] = 1.0
                status_label.text = "Un monstre emprunte un passage secret."

        monster.world_position = GRID_ORIGIN + monster.world_position + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
        monster.world_position = _world_from_cell(monster_cell) if not monster.has_path() else monster.world_position

        if monster_cell == adventurer_cell:
            if loop_rules.is_panicking():
                monster.reset_to_home(CELL_SIZE)
                monster.world_position = _world_from_cell(monster.home_cell)
                status_label.text = "Un monstre paniqué retourne dans son repaire."
            else:
                adventurer_health.take_damage(MONSTER_HIT_DAMAGE)
                monster.reset_to_home(CELL_SIZE)
                monster.world_position = _world_from_cell(monster.home_cell)

func _monster_passage_tags(index: int) -> Array[String]:
    match monster_behaviours[index]:
        PacmanLoopRules.Behaviour.CHASER:
            return ["ghost"]
        PacmanLoopRules.Behaviour.AMBUSHER, PacmanLoopRules.Behaviour.HERDER:
            return ["ambusher"]
        _:
            return ["guardian"]

func _draw() -> void:
    super._draw()
    for passage in dungeon_build.secret_passages.passages:
        var entry_center := _world_from_cell(passage.entry)
        draw_circle(entry_center, 10.0, Color("b5179e"))
        draw_circle(entry_center, 5.0, Color("7209b7"))

func _refresh_build_ui() -> void:
    super._refresh_build_ui()
    if wall_button:
        wall_button.disabled = game_state != GameState.PREPARATION
        wall_button.text = "Mur (%d/%d or)" % [dungeon_build.remaining_wall_budget(), DungeonBuildRuntime.WALL_COST]
    if remove_wall_button:
        remove_wall_button.disabled = game_state != GameState.PREPARATION

func _construction_reserved_cells() -> Array[Vector2i]:
    var reserved: Array[Vector2i] = [DOOR, BLESSING_CELL]
    reserved.append_array(COLLECTIBLE_CELLS)
    reserved.append_array(MONSTER_HOME_CELLS)
    return reserved
