class_name PathPreview
extends RefCounted

# Simple greedy path preview using expected_costs (tile->cost)
func preview_path(start: Vector2, goal: Vector2, map_data: Dictionary) -> Dictionary:
	var costs := map_data.get("expected_costs", {})
	var current := start
	var visited := {}
	var path := []
	path.append(current)
	while current != goal and path.size() < 256:
		var neighbors := [Vector2(current.x+1,current.y), Vector2(current.x-1,current.y), Vector2(current.x,current.y+1), Vector2(current.x,current.y-1)]
		var best := null
		var best_cost := 1e9
		for n in neighbors:
			if visited.has(n):
				continue
			var c := costs.get(n, 9999.0)
			if c < best_cost:
				best_cost = c
				best = n
		if best == null:
			break
		visited[best] = true
		path.append(best)
		current = best
	# aggregate danger per tile
	var preview := {}
	for p in path:
		preview[p] = costs.get(p, 0.0)
	return preview
