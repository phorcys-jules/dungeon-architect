class_name DungeonBuildRuntime
extends RefCounted

const WALL_COST := 12
const WALL_REFUND := 6

var planner := WallPlacementPlanner.new()
var secret_passages := SecretPassageNetwork.new()
var fixed_walls: Array[Vector2i] = []
var reserved_cells: Array[Vector2i] = []
var entrance := Vector2i.ZERO
var objective := Vector2i.ZERO

func configure(size: Vector2i, budget: int, base_walls: Array[Vector2i], start: Vector2i, goal: Vector2i, reserved: Array[Vector2i] = []) -> void:
    planner.configure(size, budget)
    fixed_walls = base_walls.duplicate()
    entrance = start
    objective = goal
    reserved_cells = reserved.duplicate()

func try_place_wall(cell: Vector2i, available_gold: int) -> Dictionary:
    if available_gold < WALL_COST:
        return {"ok": false, "gold_delta": 0, "reason": "not_enough_gold"}
    if not planner.place(cell, fixed_walls, entrance, objective, reserved_cells):
        return {"ok": false, "gold_delta": 0, "reason": "invalid_or_blocks_route"}
    return {"ok": true, "gold_delta": -WALL_COST, "reason": "placed"}

func try_remove_wall(cell: Vector2i) -> Dictionary:
    if not planner.remove(cell):
        return {"ok": false, "gold_delta": 0, "reason": "not_found"}
    return {"ok": true, "gold_delta": WALL_REFUND, "reason": "removed"}

func blocked_cells() -> Array[Vector2i]:
    return planner.build_blocked_cells(fixed_walls)

func remaining_wall_budget() -> int:
    return planner.remaining_budget()

func configure_default_passages() -> void:
    secret_passages.passages.clear()
    secret_passages.add_passage(Vector2i(3, 3), Vector2i(11, 7), ["ghost", "ambusher", "adventurer"], 1.5)
    secret_passages.add_passage(Vector2i(11, 7), Vector2i(3, 3), ["ghost", "ambusher", "adventurer"], 1.5)

func resolve_monster_passage(cell: Vector2i, tags: Array[String]) -> Vector2i:
    return secret_passages.destination_for(cell, tags)

func resolve_adventurer_passage(cell: Vector2i) -> Vector2i:
    return secret_passages.destination_for(cell, ["adventurer"])
