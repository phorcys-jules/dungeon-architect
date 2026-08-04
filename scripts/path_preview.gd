class_name PathPreview
extends RefCounted

# Simple greedy path preview using expected_costs (tile->cost)
func preview_path(start: Vector2, goal: Vector2, map_data: Dictionary) -> Dictionary:
	var costs: Dictionary = map_data.get("expected_costs", {}) as Dictionary
	var current: Vector2 = start
	var visited: Dictionary = {}
	var path: Array[Vector2] = [current]
	while current != goal and path.size() < 256:
		var neighbors: Array[Vector2] = [
			Vector2(current.x + 1.0, current.y),
			Vector2(current.x - 1.0, current.y),
			Vector2(current.x, current.y + 1.0),
			Vector2(current.x, current.y - 1.0),
		]
		var best: Variant = null
		var best_cost: float = INF
		for neighbor: Vector2 in neighbors:
			if visited.has(neighbor):
				continue
			var candidate_cost: float = float(costs.get(neighbor, 9999.0))
			if candidate_cost < best_cost:
				best_cost = candidate_cost
				best = neighbor
		if best == null:
			break
		var best_position := best as Vector2
		visited[best_position] = true
		path.append(best_position)
		current = best_position
	# Aggregate danger per tile.
	var preview: Dictionary = {}
	for position: Vector2 in path:
		preview[position] = float(costs.get(position, 0.0))
	return preview
