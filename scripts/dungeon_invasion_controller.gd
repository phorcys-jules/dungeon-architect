extends "res://scripts/collectible_run_controller.gd"

const BLESSING_TEXTURE := preload("res://assets/sprites/collectibles/blessing_flame.png")

const MobileMonsterScript := preload("res://scripts/monsters/mobile_monster.gd")
const PacmanLoopRulesScript := preload("res://scripts/core/pacman_loop_rules.gd")
const LabyrinthGeneratorScript := preload("res://scripts/core/labyrinth_generator.gd")
const MonsterAiCoordinatorScript := preload("res://scripts/monsters/monster_ai_coordinator.gd")
const MonsterTacticalRuntimeScript := preload("res://scripts/monsters/monster_tactical_runtime.gd")
const AdventurerCombatAiScript := preload("res://scripts/adventurers/adventurer_combat_ai.gd")
const MONSTER_ARCHETYPES: Array[MonsterArchetypeData] = [
    preload("res://resources/monsters/ghost.tres"),
    preload("res://resources/monsters/slime.tres"),
    preload("res://resources/monsters/mimic.tres"),
    preload("res://resources/monsters/spider.tres"),
]
const MONSTER_ARCHETYPE_BY_ID := {
    "ghost": MONSTER_ARCHETYPES[0], "slime": MONSTER_ARCHETYPES[1],
    "mimic": MONSTER_ARCHETYPES[2], "spider": MONSTER_ARCHETYPES[3],
}
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
var active_monster_archetypes: Array[MonsterArchetypeData] = MONSTER_ARCHETYPES.duplicate()
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
var configured_room_deck: Array[StringName] = DEFAULT_ROOM_DECK.duplicate()
var configured_biome_id := ""
var placed_rooms: Dictionary = {}
var active_biome := BiomeRuntime.new()
var adventurer_attack_cooldown := 0.0
var power_pellet_was_active := false
var round_state := PacmanRoundState.new()
var round_state_label: Label
var loot_ledger := RunLootLedger.new()

func _build_interface() -> void:
    super._build_interface()
    round_state_label = Label.new()
    round_state_label.position = Vector2(300, 80)
    round_state_label.size = Vector2(360, 20)
    round_state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    round_state_label.add_theme_font_size_override("font_size", 12)
    round_state_label.add_theme_color_override("font_color", Color("f4d35e"))
    add_child(round_state_label)

func _build_level() -> void:
    if configured_biome_id.is_empty() or not active_biome.set_active(configured_biome_id):
        active_biome.select_for_zone(campaign_seed, 0)
    room_deck.configure(ROOM_RESOURCES)
    if not room_deck.select(configured_room_deck):
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
    adventurer_attack_cooldown = 0.0
    power_pellet_was_active = false
    round_state.reset(COLLECTIBLE_CELLS.size())
    loot_ledger.reset()
    slime_trails.clear()
    spider_webs.clear()
    super._prepare_current_wave()
    _refresh_round_state()
    for index in mobile_monsters.size():
        var monster := mobile_monsters[index]
        monster.hold_at_home(active_monster_archetypes[index].get_effect(&"release_delay", float(index) * 0.8), CELL_SIZE)
        monster_burst_available[index] = true
        monster_ability_cooldowns[index] = 0.0

func _process(delta: float) -> void:
    var panic_before_tick := loop_rules.is_panicking()
    loop_rules.tick(delta)
    if panic_before_tick and not loop_rules.is_panicking():
        _on_power_pellet_expired()
    _refresh_round_state()
    adventurer_attack_cooldown = maxf(adventurer_attack_cooldown - delta, 0.0)
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
        _activate_power_pellet()

    _update_mobile_monsters(delta, current_cell)
    _check_capture(current_cell)
    queue_redraw()

func _on_adventurer_died() -> void:
    if game_state == GameState.INVASION:
        loot_ledger.capture_adventurer(_cell_from_world(adventurer_position))
    _refresh_round_state(true)
    super._on_adventurer_died()
    if game_state == GameState.WAVE_RESULT:
        result_summary.text += "\n" + loot_ledger.summary()

func _finish_campaign(victory: bool, message: String) -> void:
    if not victory:
        loot_ledger.lose_carried_loot()
    _refresh_round_state(true)
    super._finish_campaign(victory, message)

func _spawn_mobile_monsters() -> void:
    mobile_monsters.clear()
    monster_facings.clear()
    monster_attack_flashes.clear()
    monster_ability_flashes.clear()
    monster_ability_cooldowns.clear()
    monster_burst_available.clear()
    for index in active_monster_archetypes.size():
        var monster: MobileMonster = MobileMonsterScript.new()
        var archetype := active_monster_archetypes[index]
        var progression := _monster_progression_multipliers(archetype.archetype_id)
        monster.setup(MONSTER_HOME_CELLS[index], archetype.base_speed * _monster_speed_multiplier() * float(progression.speed), roundi(float(42 + archetype.base_damage * 2) * _monster_health_multiplier() * float(progression.health)))
        monster.world_position = Vector2(MONSTER_HOME_CELLS[index]) * CELL_SIZE
        mobile_monsters.append(monster)
        monster_facings.append(1.0)
        monster_attack_flashes.append(0.0)
        monster_ability_flashes.append(0.0)
        monster_ability_cooldowns.append(0.0)
        monster_burst_available.append(true)

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

    for index in mobile_monsters.size():
        var monster := mobile_monsters[index]
        var archetype := active_monster_archetypes[index]
        if not monster.is_active():
            continue
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
            var target := loop_rules.get_flee_target(monster.cell, adventurer_cell, GRID_SIZE, blocked, occupied) if loop_rules.is_panicking() else targets[index]
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
                _consume_panicked_monster(index, monster, archetype)
            else:
                var damage := roundi(float(MonsterTacticalRuntimeScript.collision_damage(archetype, monster_burst_available[index])) * _monster_damage_multiplier() * _monster_specific_damage_multiplier(archetype.archetype_id) * _monster_ambush_multiplier(archetype.archetype_id, monster_burst_available[index]))
                var attack_origin := GRID_ORIGIN + monster.world_position + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
                _play_monster_attack(archetype.archetype_id, attack_origin)
                adventurer_health.take_damage(damage)
                if archetype.has_ability(&"first_hit_burst") and monster_burst_available[index]:
                    monster_burst_available[index] = false
                    monster_ability_flashes[index] = 0.35
                    status_label.text = "Le mimic bondit hors de sa cachette : %d dégâts !" % damage
                monster_attack_flashes[index] = 0.18
                monster.reset_to_home(CELL_SIZE)

func _try_adventurer_attack() -> bool:
    if adventurer_attack_cooldown > 0.0 or adventurer_health.is_dead:
        return false
    var adventurer_data := waves.get_adventurer_data()
    var profile: Dictionary = AdventurerCombatAiScript.profile(adventurer_data.id)
    var empowered := loop_rules.is_panicking()
    var attack_range := (float(profile.range_cells) + (1.25 if empowered else 0.0)) * CELL_SIZE
    var candidates: Array[Dictionary] = []
    for index in mobile_monsters.size():
        var monster := mobile_monsters[index]
        var center := GRID_ORIGIN + monster.world_position + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
        var distance := adventurer_position.distance_to(center)
        if distance <= attack_range:
            candidates.append({
                "index": index,
                "active": monster.is_active(),
                "distance": distance / CELL_SIZE,
                "health_ratio": monster.get_health_ratio(),
                "threat": active_monster_archetypes[index].base_damage,
            })
    var target_index := AdventurerCombatAiScript.choose_target(candidates, StringName(profile.strategy))
    if target_index < 0:
        return false
    var target := mobile_monsters[target_index]
    var target_center := GRID_ORIGIN + target.world_position + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
    var damage := roundi(float(profile.damage) * (1.8 if empowered else 1.0) * (1.0 - _monster_evasion(active_monster_archetypes[target_index].archetype_id)))
    var respawn_base := active_monster_archetypes[target_index].get_effect(&"respawn_delay", 3.0)
    var respawn_delay := _monster_respawn_delay(maxf(respawn_base, loop_rules.panic_time_left + 0.5) if empowered else respawn_base)
    var applied_damage := target.take_damage(damage, respawn_delay)
    if applied_damage <= 0:
        return false
    adventurer_attack_cooldown = float(profile.cooldown) * (0.62 if empowered else 1.0)
    _play_adventurer_attack(target_center, bool(profile.ranged), empowered)
    monster_ability_flashes[target_index] = 0.2
    if target.is_active():
        status_label.text = "%s attaque %s : %d dégâts." % [adventurer_data.display_name, active_monster_archetypes[target_index].display_name, applied_damage]
    else:
        loot_ledger.record_monster_neutralized(target.cell, 1, 2)
        status_label.text = "%s neutralise %s, qui reviendra bientôt." % [adventurer_data.display_name, active_monster_archetypes[target_index].display_name]
    return true

func _activate_power_pellet() -> void:
    blessing_available = false
    loop_rules.activate_panic()
    power_pellet_was_active = true
    for index in mobile_monsters.size():
        mobile_monsters[index].path.clear()
        mobile_monsters[index].path_index = 0
        monster_ability_flashes[index] = 0.35
    adventurer_attack_cooldown = 0.0
    _spawn_combat_effect(&"splash", adventurer_position, adventurer_position, Color("fff36b"), 0.55)
    status_label.text = "Pac-gomme activée : l'aventurier chasse, les monstres fuient pendant %.0f s !" % loop_rules.panic_duration

func _consume_panicked_monster(index: int, monster: MobileMonster, archetype: MonsterArchetypeData) -> void:
    var center := GRID_ORIGIN + monster.world_position + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
    var respawn_base := archetype.get_effect(&"respawn_delay", 3.0)
    loot_ledger.record_monster_neutralized(monster.cell, 1, 2)
    monster.take_damage(monster.current_health, _monster_respawn_delay(maxf(respawn_base, loop_rules.panic_time_left + 0.5)))
    monster_ability_flashes[index] = 0.35
    _play_adventurer_attack(center, false, true)
    _spawn_combat_effect(&"splash", center, center, Color("fff36b"), 0.45)
    status_label.text = "%s dévore l'énergie de %s !" % [waves.get_adventurer_name(), archetype.display_name]

func _on_power_pellet_expired() -> void:
    if not power_pellet_was_active:
        return
    power_pellet_was_active = false
    for monster in mobile_monsters:
        monster.path.clear()
        monster.path_index = 0
    status_label.text = "La pac-gomme est épuisée : les monstres reprennent la chasse."

func _play_monster_attack(archetype_id: StringName, attack_origin: Vector2) -> void:
    match archetype_id:
        &"ghost":
            _play_clash(attack_origin, &"spectral", Color("9edcff"))
        &"slime":
            _play_clash(attack_origin, &"splash", Color("a66cff"))
        &"spider":
            _play_clash(attack_origin, &"web", Color("e4d3ff"))
        _:
            _play_clash(attack_origin, &"slash", Color("ff9f68"))

func _apply_monster_zone_ability(index: int, archetype: MonsterArchetypeData, previous_cell: Vector2i, current_cell: Vector2i) -> void:
    if archetype.has_ability(&"slow_trail"):
        slime_trails[previous_cell] = archetype.get_effect(&"trail_duration", 3.5) * _effect_duration_multiplier()
        monster_ability_flashes[index] = 0.12
    if archetype.has_ability(&"web_crossroads") and _is_crossroads(current_cell):
        spider_webs[current_cell] = archetype.get_effect(&"web_duration", 4.0) * _effect_duration_multiplier()
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
        if monster.is_active():
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
    var lair_rect := Rect2(_cell_top_left(Vector2i(6, 4)) + Vector2(4, 4), Vector2(CELL_SIZE * 3 - 8, CELL_SIZE * 3 - 8))
    draw_rect(lair_rect, Color("20152f", 0.52), true)
    draw_rect(lair_rect, Color("b995d6", 0.8), false, 2.0)
    draw_string(ThemeDB.fallback_font, lair_rect.position + Vector2(12, 17), "REPAIRE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("dec9f5"))
    for drop: Dictionary in loot_ledger.world_drops:
        var drop_center := _world_from_cell(Vector2i(drop.cell))
        var drop_color := Color("8ff0df") if String(drop.kind) == "ectoplasm" else Color("ffd166")
        draw_circle(drop_center, 8.0, Color(drop_color, 0.28))
        draw_circle(drop_center, 4.0, drop_color)
    for cell: Vector2i in slime_trails:
        var trail_center := _world_from_cell(cell)
        draw_circle(trail_center, 13.0, Color("7145c7", 0.48))
        draw_circle(trail_center, 6.0, Color("9b73ee", 0.65))
    for cell: Vector2i in spider_webs:
        _draw_web(_world_from_cell(cell))
    if blessing_available:
        _draw_collectible(BLESSING_TEXTURE, _world_from_cell(BLESSING_CELL), Vector2(40, 40))
    if loop_rules.is_panicking() and not adventurer_health.is_dead:
        var pulse := 18.0 + sin(character_animation_time * 10.0) * 3.0
        draw_circle(adventurer_position, pulse, Color("fff36b", 0.12))
        draw_arc(adventurer_position, pulse, 0.0, TAU, 24, Color("fff36b", 0.8), 2.0)
    for index in mobile_monsters.size():
        var monster := mobile_monsters[index]
        if monster.returning_home:
            var spirit_center := GRID_ORIGIN + monster.world_position + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
            draw_circle(spirit_center, 11.0, Color("a8ecff", 0.28))
            draw_arc(spirit_center, 13.0, 0.0, TAU, 16, Color("d8f7ff", 0.85), 2.0)
            continue
        if not monster.is_active():
            continue
        var center := GRID_ORIGIN + monster.world_position + Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
        var archetype := active_monster_archetypes[index]
        var texture: Texture2D = MONSTER_TEXTURES[archetype.archetype_id]
        var tint := Color("f7c66f") if monster_ability_flashes[index] > 0.0 else Color.WHITE
        if loop_rules.is_panicking():
            tint = Color("9eeeff")
        var scale := CharacterAnimationRuntimeScript.attack_scale(monster_attack_flashes[index])
        center += CharacterAnimationRuntimeScript.attack_offset(monster_attack_flashes[index], adventurer_position - center, 0.18, 11.0)
        if monster_ability_flashes[index] > 0.0:
            scale += 0.08
        _draw_character_frame(texture, center, tint, monster.has_path(), monster_facings[index], archetype.base_speed / 120.0, scale, index * 0.07)
        var health_width := 32.0
        var health_origin := center + Vector2(-health_width / 2.0, -24.0)
        draw_rect(Rect2(health_origin, Vector2(health_width, 4)), Color("261f2d"))
        draw_rect(Rect2(health_origin, Vector2(health_width * monster.get_health_ratio(), 4)), Color("e05d6f"))

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
        _slime_slow_multiplier(slime.get_effect(&"slow_multiplier", 0.72)),
        spider.get_effect(&"web_slow_multiplier", 0.58)
    )
    return super._current_adventurer_speed_multiplier() * zone_multiplier * round_state.tension_speed_multiplier()

func _refresh_round_state(resolved: bool = false) -> void:
    round_state.update(collectible_route.get_remaining_count(), loop_rules.panic_time_left, resolved)
    if round_state_label:
        round_state_label.text = round_state.label()

func get_run_tags() -> Array[String]:
    var tags: Array[String] = ["biome:%s" % active_biome.active_biome_id]
    for archetype in active_monster_archetypes:
        tags.append("monster:%s" % archetype.archetype_id)
    for room: RoomData in placed_rooms.values():
        for tag in room.tags:
            var value := "room:%s" % String(tag)
            if not tags.has(value):
                tags.append(value)
    return tags

func get_monster_ids() -> Array[String]:
    var ids: Array[String] = []
    for archetype in active_monster_archetypes:
        ids.append(archetype.archetype_id)
    return ids

func set_monster_team(monster_ids: Array[String]) -> void:
    var selected: Array[MonsterArchetypeData] = []
    for monster_id in monster_ids:
        var archetype := MONSTER_ARCHETYPE_BY_ID.get(monster_id) as MonsterArchetypeData
        if archetype != null and not selected.has(archetype):
            selected.append(archetype)
        if selected.size() >= MONSTER_HOME_CELLS.size():
            break
    active_monster_archetypes = selected if not selected.is_empty() else MONSTER_ARCHETYPES.duplicate()

func set_room_deck(room_ids: Array[String]) -> bool:
    var typed_ids: Array[StringName] = []
    for room_id in room_ids:
        typed_ids.append(StringName(room_id))
    var validator := RoomDeck.new()
    validator.configure(ROOM_RESOURCES)
    if typed_ids.is_empty() or typed_ids.size() > ROOM_ANCHORS.size() or not validator.select(typed_ids):
        return false
    configured_room_deck = typed_ids
    return true

func set_biome(biome_id: String) -> bool:
    if not active_biome.set_active(biome_id):
        return false
    configured_biome_id = biome_id
    return true

func _monster_respawn_delay(base_delay: float) -> float:
    return base_delay

func _monster_damage_multiplier() -> float:
    return 1.0

func _monster_speed_multiplier() -> float:
    return 1.0

func _monster_evasion(_archetype_id: StringName) -> float:
    return 0.0

func _monster_ambush_multiplier(_archetype_id: StringName, _first_hit: bool) -> float:
    return 1.0

func _slime_slow_multiplier(base_multiplier: float) -> float:
    return base_multiplier

func _on_collectible_loot_collected(_cell: Vector2i) -> void:
    loot_ledger.collect_relic(3)

func _monster_health_multiplier() -> float:
    return 1.0

func _monster_progression_multipliers(_archetype_id: String) -> Dictionary:
    return {"health": 1.0, "damage": 1.0, "speed": 1.0}

func _monster_specific_damage_multiplier(_archetype_id: String) -> float:
    return 1.0

func _effect_duration_multiplier() -> float:
    return 1.0

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
