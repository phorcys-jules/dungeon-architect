extends "res://scripts/main.gd"

const CollectibleRouteScript := preload("res://scripts/core/collectible_route.gd")

const COLLECTIBLE_CELLS: Array[Vector2i] = [
    Vector2i(2, 2),
    Vector2i(12, 8),
    Vector2i(10, 2),
    Vector2i(3, 8),
]

var collectible_route: CollectibleRoute = CollectibleRouteScript.new()
var active_route_target := TREASURE

func _prepare_current_wave() -> void:
    collectible_route.reset(COLLECTIBLE_CELLS)
    active_route_target = collectible_route.get_next_target(ENTRANCE)
    super._prepare_current_wave()
    status_label.text = "%s\n%s\nReliques restantes : %d" % [
        waves.get_label(),
        waves.get_briefing(),
        collectible_route.get_remaining_count(),
    ]

func _process(delta: float) -> void:
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
    adventurer_position = adventurer_position.move_toward(target, MOVE_SPEED * waves.get_speed_multiplier() * delta)
    if adventurer_position.distance_to(target) < 1.0:
        adventurer_position = target
        var reached_cell := _cell_from_world(adventurer_position)
        _trigger_trap_at(reached_cell)
        path_index += 1
        if path_index >= path.size() and not adventurer_health.is_dead:
            _on_route_target_reached(reached_cell)
    queue_redraw()

func _on_route_target_reached(cell: Vector2i) -> void:
    if collectible_route.collect_at(cell):
        status_label.text = "Relique collectée. Il en reste %d." % collectible_route.get_remaining_count()
        _recalculate_path()
        return

    if cell == TREASURE and collectible_route.can_enter_treasure():
        _finish_campaign(false, "Le trésor a été pillé après la collecte des reliques pendant la vague %d." % waves.current_wave)
        return

    _recalculate_path()

func _recalculate_path() -> void:
    var start_cell := _cell_from_world(adventurer_position)
    if not _is_inside_grid(start_cell):
        start_cell = ENTRANCE

    active_route_target = (
        collectible_route.get_next_target(start_cell)
        if collectible_route.has_remaining()
        else TREASURE
    )

    var cell_path := astar.get_id_path(start_cell, active_route_target)
    path.clear()
    path_index = 0
    for cell in cell_path:
        path.append(_world_from_cell(cell))
    if path.size() > 1:
        path.remove_at(0)

    if path.is_empty():
        _on_adventurer_died()
    elif collectible_route.has_remaining():
        status_label.text = "%s : l'aventurier cherche une relique (%d restante(s))." % [
            waves.get_label(),
            collectible_route.get_remaining_count(),
        ]
    else:
        status_label.text = "%s : toutes les reliques sont collectées, direction le trésor." % waves.get_label()

func _draw() -> void:
    super._draw()
    for cell in collectible_route.remaining:
        var center := _world_from_cell(cell)
        draw_circle(center, 8.0, Color("f4d35e"))
        draw_circle(center, 3.0, Color("fff4c2"))

func _is_valid_build_cell(cell: Vector2i) -> bool:
    return super._is_valid_build_cell(cell) and not COLLECTIBLE_CELLS.has(cell)
