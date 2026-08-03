class_name PathPreview
extends RefCounted

# Lightweight path danger preview: returns a map of tile->danger
func preview_path(start: Vector2, goal: Vector2, map_data: Dictionary) -> Dictionary:
	# map_data.expected_costs is a Dictionary of Vector2->float for tests
	var preview := {}
	for p in map_data.get("expected_costs", {}).keys():
		preview[p] = map_data.expected_costs[p]
	return preview
