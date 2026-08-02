extends "res://scripts/collectible_run_controller.gd"

const MobileMonsterScript := preload("res://scripts/monsters/mobile_monster.gd")
const PacmanLoopRulesScript := preload("res://scripts/core/pacman_loop_rules.gd")
const LabyrinthGeneratorScript := preload("res://scripts/core/labyrinth_generator.gd")

const BLESSING_CELL := Vector2i(7, 8)
const MONSTER_HOME_CELLS: Array[Vector2i] = [Vector2i(6, 5), Vector2i(8, 5)]
const MONSTER_HIT_DAMAGE := 20

var mobile_monsters: Array[MobileMonster] = []
var monster_behaviours: Array[PacmanLoopRules.Behaviour] = [PacmanLoopRules.Behaviour.CHASER, PacmanLoopRules.Behaviour.AMBUSHER]
var loop_rules: PacmanLoopRules = PacmanLoopRulesScript.new()
var labyrinth_generator: LabyrinthGenerator = LabyrinthGeneratorScript.new()
var campaign_seed := int(Time.get_unix_time_from_system())
var blessing_available := true
var last_adventurer_cell := ENTRANCE
var adventurer_direction := Vector2i.RIGHT

func _build_level() -> void:
    labyrinth_generator.size = GRID_SIZE
    labyrinth_generator.entrance = ENTRANCE
    labyrinth_generator.treasure = TREASURE
    var required_cells: Array[Vector2i] = COLLECTIBLE_CELLS.duplicate()
    required_cells.append(BLESSING_CELL)
    required_cells.append_array(MONSTER_HOME_CELLS)
    required_cells.append(DOOR)
    var layout := labyrinth_generator.generate(campaign_seed, required_cells)
    walls.assign(layout.get("walls", []))

func _ready() -> void:
    super._ready()
    _spawn_mobile_monsters()
    status_label.text += "\nSeed du labyrinthe : %d" % campaign_seed

func _prepare_current_wave() -> void:
    blessing_available = true
    super._prepare_current_wave()
    for monster in mobile_monsters:
        monster.reset_to_home(CELL_SIZE)

func _process(delta: float) -> void:
    loop_rules.tick(delta)
    super._process(delta)
    if game_state != GameState.INVASION or adventurer_health.is_dead:
        return

    var current_cell := _cell_from_world(adventurer_position)
    var movement := current_cell - last_adventurer_cell
    if movement != Vector2i.ZERO:
        adventurer_direction = Vector2i(clampi(movement.x, -1, 1), clampi(movement.y, -1, 1))
        last_adventurer_cell = current_cell

    if blessing_available and current_cell == BLESSING_CELL:
        blessing_available = false
        loop_rules.activate_panic()
        status_label.text = "Bénédiction activée : les monstres paniquent !"

    _update_mobile_monsters(delta, current_cell)
    _check_capture(current_cell)
    queue_redraw()

func _spawn_mobile_monsters() -> void:
    mobile_monsters.clear()
    for index in MONSTER_HOME_CELLS.size():
        var monster: MobileMonster = MobileMonsterScript.new()
        monster.setup(MONSTER_HOME_CELLS[index], 105.0 + index * 12.0)
        monster.world_position = _world_from_cell(MONSTER_HOME_CELLS[index])
        mobile_monsters.append(monster)

func _update_mobile_monsters(delta: float, adventurer_cell: Vector2i) -> void:
    var occupied: Array[Vector2i] = []
    for monster in mobile_monsters:
        occupied.append(monster.cell)

    for index in mobile_monsters.size():
        var monster := mobile_monsters[index]
        if not monster.has_path():
            var target := monster.home_cell if loop_rules.is_panicking() else loop_rules.get_target(monster_behaviours[index], adventurer_cell, adventurer_direction, TREASURE, active_route_target)
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
        monster.world_position = GRID_ORIGIN + monster.world_position + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
        var monster_cell := monster.cell
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

func _check_capture(adventurer_cell: Vector2i) -> void:
    var monster_cells: Array[Vector2i] = []
    for monster in mobile_monsters:
        monster_cells.append(monster.cell)
    var blocked := walls.duplicate()
    if door_closed:
        blocked.append(DOOR)
    if loop_rules.is_captured(adventurer_cell, monster_cells, blocked):
        _on_adventurer_died()
        status_label.text = "L'aventurier a été encerclé et capturé."

func _toggle_door() -> void:
    if game_state == GameState.INVASION:
        if not loop_rules.consume_door_toggle():
            status_label.text = "La porte se recharge."
            return
        door_closed = not door_closed
        astar.set_point_solid(DOOR, door_closed)
        _recalculate_path()
        status_label.text = "Porte fermée pendant l'invasion." if door_closed else "Porte ouverte pendant l'invasion."
        _refresh_door_ui()
        queue_redraw()
        return
    super._toggle_door()

func _draw() -> void:
    super._draw()
    if blessing_available:
        var blessing_center := _world_from_cell(BLESSING_CELL)
        draw_circle(blessing_center, 11.0, Color("fff3b0"))
        draw_circle(blessing_center, 5.0, Color("ffffff"))
    for index in mobile_monsters.size():
        var monster := mobile_monsters[index]
        var center := _world_from_cell(monster.cell)
        var color := Color("7bdff2") if loop_rules.is_panicking() else (Color("ff5d8f") if index == 0 else Color("ff9f1c"))
        draw_circle(center, 14.0, color)
        draw_circle(center + Vector2(-5, -4), 2.0, Color.WHITE)
        draw_circle(center + Vector2(5, -4), 2.0, Color.WHITE)

func _is_valid_build_cell(cell: Vector2i) -> bool:
    return super._is_valid_build_cell(cell) and cell != BLESSING_CELL and not MONSTER_HOME_CELLS.has(cell)
