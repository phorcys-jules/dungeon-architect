extends SceneTree

func _fail(message: String) -> void:
	push_error(message)
	quit(1)

func _init() -> void:
	var coordinator := MonsterAiCoordinator.new()
	var cells: Array[Vector2i] = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(8, 8), Vector2i(3, 3)]
	var roles: Array[PacmanLoopRules.Behaviour] = [
		PacmanLoopRules.Behaviour.CHASER,
		PacmanLoopRules.Behaviour.AMBUSHER,
		PacmanLoopRules.Behaviour.GUARDIAN,
		PacmanLoopRules.Behaviour.HERDER,
	]
	var targets := coordinator.assign_targets(cells, roles, Vector2i(5, 5), Vector2i.RIGHT, Vector2i(9, 9), Vector2i(0, 5), [])
	if targets.size() != 4:
		_fail("Expected one target per monster")
	if targets[2].distance_to(Vector2i(9, 9)) > coordinator.guardian_radius:
		_fail("Guardian left the treasure zone")
	if targets[3] == targets[0] or targets[3] == targets[1]:
		_fail("Herder duplicated another monster target")
	var nearby := coordinator.assign_targets([Vector2i(8, 9)], [PacmanLoopRules.Behaviour.GUARDIAN], Vector2i(8, 8), Vector2i.LEFT, Vector2i(9, 9), Vector2i.ZERO, [])
	if nearby[0] != Vector2i(8, 8):
		_fail("Guardian did not intercept an adventurer near the treasure")
	print("monster AI coordinator test passed")
	quit()
