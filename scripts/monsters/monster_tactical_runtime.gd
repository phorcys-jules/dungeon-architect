class_name MonsterTacticalRuntime
extends RefCounted

static func tactical_target(
    archetype_id: String,
    default_target: Vector2i,
    adventurer: Vector2i,
    direction: Vector2i,
    room_cells: Dictionary,
    active_webs: Dictionary
) -> Vector2i:
    match archetype_id:
        "slime":
            return adventurer + direction * 2
        "mimic":
            var bait := _room_cell(room_cells, "false_treasure")
            return adventurer if bait == Vector2i(-1, -1) or adventurer.distance_to(bait) <= 4.0 else bait
        "spider":
            var crossroads := _room_cell(room_cells, "crossroads")
            return crossroads if crossroads != Vector2i(-1, -1) and not active_webs.has(crossroads) else default_target
        _:
            return default_target

static func phase_destination(
    start: Vector2i,
    target: Vector2i,
    walls: Array[Vector2i],
    grid_size: Vector2i
) -> Vector2i:
    var delta := target - start
    var direction := Vector2i(signi(delta.x), 0) if abs(delta.x) >= abs(delta.y) else Vector2i(0, signi(delta.y))
    var wall_cell := start + direction
    var landing := wall_cell + direction
    if walls.has(wall_cell) and _inside(landing, grid_size) and not walls.has(landing):
        return landing
    return start

static func collision_damage(archetype: MonsterArchetypeData, burst_available: bool) -> int:
    var damage := archetype.base_damage
    if burst_available and archetype.has_ability(&"first_hit_burst"):
        damage = roundi(float(damage) * archetype.get_effect(&"first_hit_multiplier", 1.0))
    return damage

static func movement_multiplier(on_slime: bool, on_web: bool, slime_multiplier: float, web_multiplier: float) -> float:
    var result := 1.0
    if on_slime:
        result = minf(result, slime_multiplier)
    if on_web:
        result = minf(result, web_multiplier)
    return result

static func _room_cell(room_cells: Dictionary, room_id: String) -> Vector2i:
    for cell: Vector2i in room_cells:
        var room: RoomData = room_cells[cell]
        if room.room_id == room_id:
            return cell
    return Vector2i(-1, -1)

static func _inside(cell: Vector2i, grid_size: Vector2i) -> bool:
    return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size.x and cell.y < grid_size.y
