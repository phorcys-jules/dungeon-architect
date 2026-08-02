extends "res://scripts/collectible_run_controller.gd"

const BLESSING_TEXTURE := preload("res://assets/sprites/collectibles/blessing_flame.png")

const MobileMonsterScript := preload("res://scripts/monsters/mobile_monster.gd")
const PacmanLoopRulesScript := preload("res://scripts/core/pacman_loop_rules.gd")
const LabyrinthGeneratorScript := preload("res://scripts/core/labyrinth_generator.gd")
const MonsterAiCoordinatorScript := preload("res://scripts/monsters/monster_ai_coordinator.gd")
const MonsterTacticalRuntimeScript := preload("res://scripts/monsters/monster_tactical_runtime.gd")
const MONSTER_ARCHETYPES: Array[MonsterArchetypeData] = [
    preload("res://resources/monsters/ghost.tres"),
    preload("res://resources/monsters/slime.tres"),
    preload("res://resources/monsters/mimic.tres"),
    preload("res://resources/monsters/spider.tres"),
]
const MONSTER_TEXTURES := {
    "ghost": preload("res://assets/sprites/characters/animations/monster_ghost_walk.png"),
    "slime": preload("res://assets/sprites/characters/animations/monster_slime_walk.png"),
    "mimic": preload("res://assets/sprites/characters/animations/monster_mimic_walk.png"),
    "spider": preload("res://assets/sprites/characters/animations/monster_spider_walk.png"),
}
const ROOM_TEXTURES := {
    "slime_pool": preload("res://assets/sprites/rooms/slime_pool.png"),
    "crossroads": preload("res://assets/sprites/rooms/crossroads.png"),
    "false_treasure": preload("res://assets/sprites/rooms/false_treasure.png"),
    "monster_portal": preload("res://assets/sprites/rooms/monster_portal.png"),
    "fog_chamber": preload("res://assets/sprites/rooms/fog_chamber.png"),
}
const ROOM_RESOURCES: Array[RoomData] = [
    preload("res://resources/rooms/corridor.tres"),
    preload("res://resources/rooms/crossroads.tres"),
    preload("res://resources/rooms/fog_chamber.tres"),
    preload("res://resources/rooms/slime_pool.tres"),
    preload("res://resources/rooms/false_treasure.tres"),
    preload("res://resources/rooms/monster_portal.tres"),
    preload("res://resources/rooms/ice_gallery.tres"),
    preload("res://resources/rooms/cursed_shrine.tres"),
    preload("res://resources/rooms/treasure_hall.tres"),
]
const DEFAULT_ROOM_DECK: Array[StringName] = [&"fog_chamber", &"slime_pool", &"false_treasure", &"crossroads", &"monster_portal"]
const ROOM_ANCHORS: Array[Vector2i] = [Vector2i(3, 2), Vector2i(7, 2), Vector2i(11, 3), Vector2i(4, 8), Vector2i(10, 8)]

const BLESSING_CELL := Vector2i(7, 8)
const MONSTER_HOME_CELLS: Array[Vector2i] = [Vector2i(6, 5), Vector2i(8, 5), Vector2i(7, 4), Vector2i(7, 6)]
const MONSTER_HIT_DAMAGE := 20

var mobile_monsters: Array[MobileMonster] = []
var monster_behaviours: Array[PacmanLoopRules.Behaviour] = [
    PacmanLoopRules.Behaviour.CHASER,
    PacmanLoopRules.Behaviour.AMBUSHER,
    PacmanLoopRules.Behaviour.GUARDIAN,
    PacmanLoopRules.Behaviour.HERDER,
]
var loop_rules: PacmanLoopRules = PacmanLoopRulesScript.new()
var labyrinth_generator: LabyrinthGenerator = LabyrinthGeneratorScript.new()
var monster_ai: MonsterAiCoordinator = MonsterAiCoordinatorScript.new()
var monster_facings: Array[float] = []
var monster_attack_flashes: Array[float] = []
var monster_ability_flashes: Array[float] = []
var monster_ability_cooldowns: Array[float] = []
var monster_burst_available: Array[bool] = []
var slime_trails: Dictionary = {}
var spider_webs: Dictionary = {}
var campaign_seed := int(Time.get_unix_time_from_system())
var blessing_available := true
var last_adventurer_cell := ENTRANCE
var adventurer_direction := Vector2i.RIGHT
var room_deck := RoomDeck.new()
var placed_rooms: Dictionary = {}
var active_biome := BiomeRuntime.new()

func _build_level() -> void:
    active_biome.select_for_zone(campaign_seed, 0)
    room_deck.configure(ROOM_RESOURCES)
    room_deck.select(DEFAULT_ROOM_DECK)
    room_deck.shuffle(campaign_seed)
    placed_rooms.clear()
    var room_cells: Array[Vector2i] = []
    for anchor in ROOM_ANCHORS:
        var room := room_deck.draw()
        if room != null:
            placed_rooms[anchor] = room
            room_cells.append(anchor)
    labyrinth_generator.size = GRID_SIZE
    labyrinth_generator.entrance = ENTRANCE
    labyrinth_generator.treasure = TREASURE
    var required_cells: Array[Vector2i] = COLLECTIBLE_CELLS.duplicate()
    required_cells.append(BLESSING_CELL)
    required_cells.append_array(MONSTER_HOME_CELLS)
    required_cells.append(DOOR)
    required_cells.append_array(room_cells)
    var layout := labyrinth_generator.generate(campaign_seed, required_cells)
    walls.assign(layout.get("walls", []))

func _ready() -> void:
    super._ready()
    _spawn_mobile_monsters()
    status_label.text += "\nSeed du labyrinthe : %d" % campaign_seed

func _prepare_current_wave() -> void:
    blessing_available = true
    slime_trails.clear()
    spider_webs.clear()
    super._prepare_current_wave()
    for index in mobile_monsters.size():
        var monster := mobile_monsters[index]
        monster.reset_to_home(CELL_SIZE)
        monster_burst_available[index] = true
        monster_ability_cooldowns[index] = 0.0

func _process(delta: float) -> void:
    loop_rules.tick(delta)
    for index in monster_attack_flashes.size():
        monster_attack_flashes[index] = maxf(monster_attack_flashes[index] - delta, 0.0)
        monster_ability_flashes[index] = maxf(monster_ability_flashes[index] - delta, 0.0)
        monster_ability_cooldowns[index] = maxf(monster_ability_cooldowns[index] - delta, 0.0)
    _tick_zone_durations(slime_trails, delta)
    _tick_zone_durations(spider_webs, delta)
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
    monster_facings.clear()
    monster_attack_flashes.clear()
    monster_ability_flashes.clear()
    monster_ability_cooldowns.clear()
    monster_burst_available.clear()
    for index in MONSTER_HOME_CELLS.size():
        var monster: MobileMonster = MobileMonsterScript.new()
        var archetype := MONSTER_ARCHETYPES[index]
        monster.setup(MONSTER_HOME_CELLS[index], archetype.base_speed)
        monster.world_position = Vector2(MONSTER_HOME_CELLS[index]) * CELL_SIZE
        mobile_monsters.append(monster)
        monster_facings.append(1.0)
        monster_attack_flashes.append(0.0)
        monster_ability_flashes.append(0.0)
        monster_ability_cooldowns.append(0.0)
        monster_burst_available.append(true)

func _update_mobile_monsters(delta: float, adventurer_cell: Vector2i) -> void:
    var occupied: Array[Vector2i] = []
    for monster in mobile_monsters:
        occupied.append(monster.cell)

    var blocked: Array[Vector2i] = walls.duplicate()
    if door_closed:
        blocked.append(DOOR)
    var targets := monster_ai.assign_targets(occupied, monster_behaviours, adventurer_cell, adventurer_direction, TREASURE, active_route_target, blocked)

    for index in mobile_monsters.size():
        var monster := mobile_monsters[index]
        var archetype := MONSTER_ARCHETYPES[index]
        if archetype.has_ability(&"phase") and monster_ability_cooldowns[index] <= 0.0:
            var landing := MonsterTacticalRuntimeScript.phase_destination(monster.cell, adventurer_cell, walls, GRID_SIZE)
            if landing != monster.cell:
                monster.cell = landing
                monster.world_position = Vector2(landing) * CELL_SIZE
                monster.path.clear()
                monster.path_index = 0
                monster_ability_cooldowns[index] = archetype.get_effect(&"phase_cooldown", 5.0)
                monster_ability_flashes[index] = 0.35
                status_label.text = "Le fantôme traverse un mur pour intercepter l'aventurier."

        if not monster.has_path():
            var target := monster.home_cell if loop_rules.is_panicking() else targets[index]
            if not loop_rules.is_panicking():
                target = MonsterTacticalRuntimeScript.tactical_target(
                    archetype.archetype_id,
                    target,
                    adventurer_cell,
                    adventurer_direction,
                    placed_rooms,
                    spider_webs
                )
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
            _apply_monster_zone_ability(index, archetype, previous_cell, monster_cell)

        if monster_cell == adventurer_cell:
            if loop_rules.is_panicking():
                monster.reset_to_home(CELL_SIZE)
                status_label.text = "Un monstre paniqué retourne dans son repaire."
            else:
                var damage := MonsterTacticalRuntimeScript.collision_damage(archetype, monster_burst_available[index])
                adventurer_health.take_damage(damage)
                if archetype.has_ability(&"first_hit_burst") and monster_burst_available[index]:
                    monster_burst_available[index] = false
                    monster_ability_flashes[index] = 0.35
                    status_label.text = "Le mimic bondit hors de sa cachette : %d dégâts !" % damage
                monster_attack_flashes[index] = 0.18
                monster.reset_to_home(CELL_SIZE)

func _apply_monster_zone_ability(index: int, archetype: MonsterArchetypeData, previous_cell: Vector2i, current_cell: Vector2i) -> void:
    if archetype.has_ability(&"slow_trail"):
        slime_trails[previous_cell] = archetype.get_effect(&"trail_duration", 3.5)
        monster_ability_flashes[index] = 0.12
    if archetype.has_ability(&"web_crossroads") and _is_crossroads(current_cell):
        spider_webs[current_cell] = archetype.get_effect(&"web_duration", 4.0)
        monster_ability_flashes[index] = 0.3
        status_label.text = "L'araignée tisse une toile au carrefour."

func _is_crossroads(cell: Vector2i) -> bool:
    if placed_rooms.has(cell):
        return (placed_rooms[cell] as RoomData).room_id == "crossroads"
    var exits := 0
    for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
        var neighbour: Vector2i = cell + direction
        if _is_inside_grid(neighbour) and not walls.has(neighbour):
            exits += 1
    return exits >= 3

func _tick_zone_durations(zones: Dictionary, delta: float) -> void:
    for cell in zones.keys():
        var remaining := float(zones[cell]) - delta
        if remaining <= 0.0:
            zones.erase(cell)
        else:
            zones[cell] = remaining

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

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var cell := _cell_from_world(event.position)
        if placed_rooms.has(cell):
            var room: RoomData = placed_rooms[cell]
            status_label.text = "%s — %s" % [room.display_name, _room_effect_description(room.room_id)]
            return
    super._unhandled_input(event)

func _room_effect_description(room_id: String) -> String:
    match room_id:
        "slime_pool": return "ralentit les aventuriers et renforce les synergies de slime."
        "crossroads": return "crée quatre connexions et améliore le contrôle des passages."
        "false_treasure": return "sert d'appât et prépare les embuscades du mimic."
        "monster_portal": return "offre une route de mobilité rapide aux monstres."
        "fog_chamber": return "dissimule les défenseurs et renforce les fantômes."
        _:
            return "salle spéciale du deck de donjon."

func _draw() -> void:
    super._draw()
    for cell: Vector2i in slime_trails:
        var trail_center := _world_from_cell(cell)
        draw_circle(trail_center, 13.0, Color("7145c7", 0.48))
        draw_circle(trail_center, 6.0, Color("9b73ee", 0.65))
    for cell: Vector2i in spider_webs:
        _draw_web(_world_from_cell(cell))
    if blessing_available:
        _draw_collectible(BLESSING_TEXTURE, _world_from_cell(BLESSING_CELL), Vector2(40, 40))
    for index in mobile_monsters.size():
        var monster := mobile_monsters[index]
        var center := GRID_ORIGIN + monster.world_position + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
        var archetype := MONSTER_ARCHETYPES[index]
        var texture: Texture2D = MONSTER_TEXTURES[archetype.archetype_id]
        var tint := Color("f7c66f") if monster_ability_flashes[index] > 0.0 else Color.WHITE
        if loop_rules.is_panicking():
            tint = Color("9eeeff")
        var scale := CharacterAnimationRuntimeScript.attack_scale(monster_attack_flashes[index])
        if monster_ability_flashes[index] > 0.0:
            scale += 0.08
        _draw_character_frame(texture, center, tint, monster.has_path(), monster_facings[index], archetype.base_speed / 120.0, scale, index * 0.07)

func _draw_web(center: Vector2) -> void:
    var color := Color("d6c5f0", 0.7)
    for radius in [6.0, 12.0, 18.0]:
        draw_arc(center, radius, 0.0, TAU, 16, color, 1.0)
    for direction in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
        draw_line(center, center + direction * 18.0, color, 1.0)

func _current_adventurer_speed_multiplier() -> float:
    var current_cell := _cell_from_world(adventurer_position)
    var slime := MONSTER_ARCHETYPES[1]
    var spider := MONSTER_ARCHETYPES[3]
    var zone_multiplier := MonsterTacticalRuntimeScript.movement_multiplier(
        slime_trails.has(current_cell),
        spider_webs.has(current_cell),
        slime.get_effect(&"slow_multiplier", 0.72),
        spider.get_effect(&"web_slow_multiplier", 0.58)
    )
    return super._current_adventurer_speed_multiplier() * zone_multiplier

func get_run_tags() -> Array[String]:
    var tags: Array[String] = ["biome:%s" % active_biome.active_biome_id]
    for archetype in MONSTER_ARCHETYPES:
        tags.append("monster:%s" % archetype.archetype_id)
    for room: RoomData in placed_rooms.values():
        for tag in room.tags:
            var value := "room:%s" % String(tag)
            if not tags.has(value):
                tags.append(value)
    return tags

func get_monster_ids() -> Array[String]:
    var ids: Array[String] = []
    for archetype in MONSTER_ARCHETYPES:
        ids.append(archetype.archetype_id)
    return ids

func _draw_level_objects() -> void:
    super._draw_level_objects()
    for cell: Vector2i in placed_rooms:
        var room: RoomData = placed_rooms[cell]
        var rect := Rect2(_cell_top_left(cell) + Vector2(3, 3), Vector2(CELL_SIZE - 6, CELL_SIZE - 6))
        var texture: Texture2D = ROOM_TEXTURES.get(room.room_id)
        if texture != null:
            draw_texture_rect(texture, rect, false)
        else:
            draw_rect(rect, Color("58446f"), true)
        draw_rect(rect, Color("b995d6"), false, 1.5)

func _is_valid_build_cell(cell: Vector2i) -> bool:
    return super._is_valid_build_cell(cell) and cell != BLESSING_CELL and not MONSTER_HOME_CELLS.has(cell) and not placed_rooms.has(cell)
