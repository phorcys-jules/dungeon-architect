class_name MonsterAiCoordinator
extends RefCounted

var guardian_radius := 4
var herder_lookahead := 4

func assign_targets(
	monster_cells: Array[Vector2i],
	behaviours: Array[PacmanLoopRules.Behaviour],
	adventurer: Vector2i,
	direction: Vector2i,
	treasure: Vector2i,
	exit_hint: Vector2i,
	blocked_cells: Array[Vector2i]
) -> Array[Vector2i]:
	var targets: Array[Vector2i] = []
	var reserved: Array[Vector2i] = []
	for index in monster_cells.size():
		var behaviour := behaviours[index] if index < behaviours.size() else PacmanLoopRules.Behaviour.CHASER
		var target := _target_for(behaviour, monster_cells[index], adventurer, direction, treasure, exit_hint, blocked_cells, reserved)
		targets.append(target)
		reserved.append(target)
	return targets

func _target_for(
	behaviour: PacmanLoopRules.Behaviour,
	monster_cell: Vector2i,
	adventurer: Vector2i,
	direction: Vector2i,
	treasure: Vector2i,
	exit_hint: Vector2i,
	blocked_cells: Array[Vector2i],
	reserved: Array[Vector2i]
) -> Vector2i:
	match behaviour:
		PacmanLoopRules.Behaviour.GUARDIAN:
			return _guardian_target(monster_cell, adventurer, treasure, blocked_cells, reserved)
		PacmanLoopRules.Behaviour.HERDER:
			return _herder_target(adventurer, direction, exit_hint, blocked_cells, reserved)
		PacmanLoopRules.Behaviour.AMBUSHER:
			return _first_available(adventurer + direction * 3, adventurer, blocked_cells, reserved)
		_:
			return _first_available(adventurer, exit_hint, blocked_cells, reserved)

func _guardian_target(
	monster_cell: Vector2i,
	adventurer: Vector2i,
	treasure: Vector2i,
	blocked_cells: Array[Vector2i],
	reserved: Array[Vector2i]
) -> Vector2i:
	if adventurer.distance_to(treasure) <= guardian_radius:
		return _first_available(adventurer, treasure, blocked_cells, reserved)
	if monster_cell.distance_to(treasure) > guardian_radius:
		return _first_available(treasure, monster_cell, blocked_cells, reserved)
	return _first_available(monster_cell, treasure, blocked_cells, reserved)

func _herder_target(
	adventurer: Vector2i,
	direction: Vector2i,
	exit_hint: Vector2i,
	blocked_cells: Array[Vector2i],
	reserved: Array[Vector2i]
) -> Vector2i:
	var forward := adventurer + direction * herder_lookahead
	var candidates: Array[Vector2i] = [forward, exit_hint, adventurer + Vector2i(direction.y, -direction.x) * 2, adventurer + Vector2i(-direction.y, direction.x) * 2]
	for candidate in candidates:
		if not blocked_cells.has(candidate) and not reserved.has(candidate):
			return candidate
	return adventurer

func _first_available(primary: Vector2i, fallback: Vector2i, blocked_cells: Array[Vector2i], reserved: Array[Vector2i]) -> Vector2i:
	if not blocked_cells.has(primary) and not reserved.has(primary):
		return primary
	if not blocked_cells.has(fallback) and not reserved.has(fallback):
		return fallback
	return primary
