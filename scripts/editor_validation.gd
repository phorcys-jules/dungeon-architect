class_name EditorValidator
extends RefCounted

# Simple layout validator: checks if at least one path exists from entrance to exit using passable tiles.
# map: {width:int, height:int, tiles: Dictionary<Vector2, bool>, entrance: Vector2, exit: Vector2}
func is_layout_solvable(map: Dictionary) -> bool:
	var entrance: Variant = map.get("entrance", null)
	var exit: Variant = map.get("exit", null)
	if entrance == null or exit == null:
		return false
	if not entrance is Vector2 or not exit is Vector2:
		return false
	var width := int(map.get("width", 0))
	var height := int(map.get("height", 0))
	var tiles: Dictionary = map.get("tiles", {})
	var visited: Dictionary = {}
	var queue: Array[Vector2] = [entrance as Vector2]
	visited[entrance] = true
	while not queue.is_empty():
		var position: Vector2 = queue.pop_front()
		if position == exit:
			return true
		var neighbors: Array[Vector2] = [
			Vector2(position.x + 1, position.y),
			Vector2(position.x - 1, position.y),
			Vector2(position.x, position.y + 1),
			Vector2(position.x, position.y - 1),
		]
		for neighbor: Vector2 in neighbors:
			if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= width or neighbor.y >= height:
				continue
			if visited.has(neighbor):
				continue
			if not bool(tiles.get(neighbor, false)):
				continue
			visited[neighbor] = true
			queue.append(neighbor)
	return false
