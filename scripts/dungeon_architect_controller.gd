extends "res://scripts/game_controller.gd"

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

func _activate_extended_build_shortcut(slot: int) -> void:
    match slot:
        8:
            _set_construction_mode(ConstructionMode.PLACE_WALL)
            status_label.text = "[8] Placement de mur sélectionné."
        9:
            _set_construction_mode(ConstructionMode.REMOVE_WALL)
            status_label.text = "[9] Retrait de mur sélectionné."

func _active_build_shortcut() -> int:
    match construction_mode:
        ConstructionMode.PLACE_WALL: return 8
        ConstructionMode.REMOVE_WALL: return 9
        _: return super._active_build_shortcut()

func _refresh_shortcut_bar() -> void:
    super._refresh_shortcut_bar()
    if shortcut_buttons.has(8):
        (shortcut_buttons[8] as Button).tooltip_text = "8 — Placer un mur"
        (shortcut_buttons[9] as Button).tooltip_text = "9 — Retirer un mur construit"

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
    _on_defense_placed(cell, "wall", DungeonBuildRuntime.WALL_COST, self)
    record_v06_wall_placed()
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

func _remove_evolved_wall(cell: Vector2i) -> bool:
    var result := dungeon_build.try_remove_wall(cell)
    if not bool(result.ok):
        return false
    walls.erase(cell)
    astar.set_point_solid(cell, false)
    _recalculate_path()
    return true

func _synchronize_wall_pathfinding() -> void:
    for x in GRID_SIZE.x:
        for y in GRID_SIZE.y:
            astar.set_point_solid(Vector2i(x, y), false)
    for cell in dungeon_build.blocked_cells():
        astar.set_point_solid(cell, true)
    astar.set_point_solid(DOOR, door_closed)

func _update_mobile_monsters(delta: float, adventurer_cell: Vector2i) -> void:
    for monster in mobile_monsters:
        monster.tick_respawn(delta, CELL_SIZE)
    _try_adventurer_attack()
    var occupied: Array[Vector2i] = []
    for monster in mobile_monsters:
        if monster.is_active():
            occupied.append(monster.cell)

    var blocked: Array[Vector2i] = walls.duplicate()
    if door_closed:
        blocked.append(DOOR)
    var targets := monster_ai.assign_targets(occupied, monster_behaviours, adventurer_cell, adventurer_direction, TREASURE, active_route_target, blocked)
    if not loop_rules.is_panicking():
        for index in mini(targets.size(), active_monster_archetypes.size()):
            var monster_id := String(active_monster_archetypes[index].archetype_id)
            var patrol_target := v06_integration.v08.patrols.target_for(monster_id, mobile_monsters[index].cell, adventurer_cell if mobile_monsters[index].cell.distance_to(adventurer_cell) <= 3.0 else Vector2i(-1, -1))
            if String(patrol_target.get("source", "idle")) != "idle":
                targets[index] = Vector2i(patrol_target.target)
            var leader_cell: Vector2i = mobile_monsters[0].cell if not mobile_monsters.is_empty() else targets[index]
            var formation_target := v06_integration.v08.formations.target_for(monster_id, leader_cell, TREASURE)
            if String(formation_target.get("source", "unassigned")) != "unassigned":
                targets[index] = Vector2i(formation_target.target)

    for index in mobile_monsters.size():
        passage_cooldowns[index] = maxf(float(passage_cooldowns.get(index, 0.0)) - delta, 0.0)
        var monster := mobile_monsters[index]
        if not monster.is_active():
            continue
        if not monster.has_path():
            var target := loop_rules.get_flee_target(monster.cell, adventurer_cell, GRID_SIZE, blocked, occupied) if loop_rules.is_panicking() else targets[index]
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

        var previous_position := monster.world_position
        var previous_cell := monster.cell
        var reached_cell := monster.tick_grid(delta, CELL_SIZE)
        monster_facings[index] = CharacterAnimationRuntimeScript.facing_sign(monster.world_position.x - previous_position.x, monster_facings[index])
        var monster_cell := monster.cell
        if reached_cell:
            _apply_monster_zone_ability(index, active_monster_archetypes[index], previous_cell, monster_cell)
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

        if monster_cell == adventurer_cell:
            if loop_rules.is_panicking():
                _consume_panicked_monster(index, monster, active_monster_archetypes[index])
            else:
                var attack_origin := GRID_ORIGIN + monster.world_position + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
                _play_monster_attack(active_monster_archetypes[index].archetype_id, attack_origin)
                var monster_damage := float(MONSTER_HIT_DAMAGE) * _monster_damage_multiplier()
                monster_damage *= _monster_specific_damage_multiplier(active_monster_archetypes[index].archetype_id)
                adventurer_health.take_damage(roundi(monster_damage))
                monster_attack_flashes[index] = 0.18
                monster.reset_to_home(CELL_SIZE)

func _monster_passage_tags(index: int) -> Array[String]:
    var tags: Array[String] = []
    for tag in active_monster_archetypes[index].tags:
        tags.append(String(tag))
    match monster_behaviours[index]:
        PacmanLoopRules.Behaviour.CHASER:
            tags.append("chaser")
        PacmanLoopRules.Behaviour.AMBUSHER, PacmanLoopRules.Behaviour.HERDER:
            tags.append("ambusher")
        _:
            tags.append("guardian")
    return tags

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
        wall_button.tooltip_text = "8 — Placer un mur (%d restant(s), %d or)" % [dungeon_build.remaining_wall_budget(), DungeonBuildRuntime.WALL_COST]
    if remove_wall_button:
        remove_wall_button.disabled = game_state != GameState.PREPARATION
        remove_wall_button.tooltip_text = "9 — Retirer un mur construit (%d or remboursés)" % DungeonBuildRuntime.WALL_REFUND

func _construction_reserved_cells() -> Array[Vector2i]:
    var reserved: Array[Vector2i] = [DOOR, BLESSING_CELL]
    reserved.append_array(COLLECTIBLE_CELLS)
    reserved.append_array(MONSTER_HOME_CELLS)
    return reserved
