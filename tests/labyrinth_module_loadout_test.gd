extends SceneTree

const GeneratorScript := preload("res://scripts/core/labyrinth_generator.gd")

func _init() -> void:
    var loadout := LabyrinthModuleLoadout.new()
    var buildings := {"forge": 1, "laboratory": 1, "graveyard": 1}
    var valid_team: Array[String] = ["crossroad_core", "loop_network"]
    assert(bool(loadout.select(valid_team, buildings).ok))
    assert(loadout.complexity_used() == 4)
    var too_complex: Array[String] = ["corridor_network", "crossroad_core", "loop_network", "route_gates"]
    assert(not bool(loadout.select(too_complex, buildings).ok))
    var locked := LabyrinthModuleLoadout.new()
    var locked_selection: Array[String] = ["crossroad_core"]
    assert(not bool(locked.select(locked_selection, {}).ok))

    var modifiers := loadout.generator_modifiers()
    var generator: LabyrinthGenerator = GeneratorScript.new()
    generator.minimum_loops += int(modifiers.loops)
    generator.wall_density += float(modifiers.density)
    generator.route_gate_count += int(modifiers.gates)
    var required: Array[Vector2i] = [Vector2i(2, 2), Vector2i(12, 8)]
    for seed_value in range(300, 500):
        assert(generator.is_valid(generator.generate(seed_value, required), required))

    var saved := loadout.to_dict()
    var restored := LabyrinthModuleLoadout.new()
    restored.from_dict(saved, buildings)
    assert(restored.selected == loadout.selected)
    print("Labyrinth module loadout test passed")
    quit(0)
