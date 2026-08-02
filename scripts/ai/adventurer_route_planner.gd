class_name AdventurerRoutePlanner
extends RefCounted

const INF_COST := 1.0e20

func find_path(graph: Dictionary, start: Vector2i, goal: Vector2i, risk: Dictionary = {}) -> Array[Vector2i]:
    if start == goal:
        return [start]
    if not graph.has(start) or not graph.has(goal):
        return []

    var frontier: Array[Vector2i] = [start]
    var costs := {start: 0.0}
    var previous := {}

    while not frontier.is_empty():
        var current := _take_lowest(frontier, costs)
        if current == goal:
            return _reconstruct(previous, start, goal)
        for neighbor_variant in graph.get(current, []):
            var neighbor: Vector2i = neighbor_variant
            var step_cost := 1.0 + maxf(float(risk.get(neighbor, 0.0)), 0.0)
            var candidate := float(costs[current]) + step_cost
            if candidate < float(costs.get(neighbor, INF_COST)):
                costs[neighbor] = candidate
                previous[neighbor] = current
                if not frontier.has(neighbor):
                    frontier.append(neighbor)
    return []

func choose_goal(origin: Vector2i, goals: Array[Dictionary], risk: Dictionary = {}) -> Dictionary:
    var best := {}
    var best_score := INF_COST
    for goal in goals:
        var position: Vector2i = goal.get("position", origin)
        var priority := float(goal.get("priority", 0.0))
        var distance: int = absi(position.x - origin.x) + absi(position.y - origin.y)
        var score := float(distance) + float(risk.get(position, 0.0)) - priority
        if score < best_score:
            best_score = score
            best = goal
    return best

func _take_lowest(frontier: Array[Vector2i], costs: Dictionary) -> Vector2i:
    var best_index := 0
    var best_cost := float(costs.get(frontier[0], INF_COST))
    for index in range(1, frontier.size()):
        var candidate_cost := float(costs.get(frontier[index], INF_COST))
        if candidate_cost < best_cost or (is_equal_approx(candidate_cost, best_cost) and _is_before(frontier[index], frontier[best_index])):
            best_index = index
            best_cost = candidate_cost
    return frontier.pop_at(best_index)

func _is_before(left: Vector2i, right: Vector2i) -> bool:
    return left.y < right.y or (left.y == right.y and left.x < right.x)

func _reconstruct(previous: Dictionary, start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
    var result: Array[Vector2i] = [goal]
    var current := goal
    while current != start:
        if not previous.has(current):
            return []
        current = previous[current]
        result.push_front(current)
    return result
