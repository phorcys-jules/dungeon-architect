class_name EditorValidator
extends RefCounted

# Simple layout validator: checks if at least one path exists from entrance to exit using passable tiles
# map: {width:int, height:int, tiles: Dictionary<Vector2, bool>, entrance: Vector2, exit: Vector2}
func is_layout_solvable(map: Dictionary) -> bool:
	var entrance := map.get("entrance", null)
	var exit := map.get("exit", null)
	if entrance == null or exit == null:
		return false
	var width := int(map.get("width", 0))
	var height := int(map.get("height", 0))
	var tiles := map.get("tiles", {})
	var visited := {}
	var queue := [entrance]
	visited[entrance] = true
	while queue.size() > 0:
		var pos = queue.pop_front()
		if pos == exit:
			return true
		var neigh = [Vector2(pos.x+1,pos.y), Vector2(pos.x-1,pos.y), Vector2(pos.x,pos.y+1), Vector2(pos.x,pos.y-1)]
		for n in neigh:
			if n.x < 0 or n.y < 0 or n.x >= width or n.y >= height:
				continue
			if visited.has(n):
				continue
			if not tiles.get(n, false):
				continue
			visited[n] = true
			queue.append(n)
	return false
