extends SceneTree

const Planner := preload("res://scripts/ai/adventurer_route_planner.gd")

func _init() -> void:
    var planner := Planner.new()
    var graph := {
        Vector2i(0, 0): [Vector2i(1, 0), Vector2i(0, 1)],
        Vector2i(1, 0): [Vector2i(0, 0), Vector2i(2, 0)],
        Vector2i(2, 0): [Vector2i(1, 0), Vector2i(2, 1)],
        Vector2i(0, 1): [Vector2i(0, 0), Vector2i(1, 1)],
        Vector2i(1, 1): [Vector2i(0, 1), Vector2i(2, 1)],
        Vector2i(2, 1): [Vector2i(1, 1), Vector2i(2, 0)]
    }
    var safe_path := planner.find_path(graph, Vector2i(0, 0), Vector2i(2, 1), {Vector2i(1, 0): 10.0})
    if safe_path != [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]:
        quit(1)
        return
    var goal := planner.choose_goal(Vector2i.ZERO, [
        {"id": "heal", "position": Vector2i(1, 0), "priority": 0.0},
        {"id": "treasure", "position": Vector2i(3, 0), "priority": 5.0}
    ])
    if goal.get("id") != "treasure":
        quit(1)
        return
    print("Adventurer route planner test passed")
    quit(0)
