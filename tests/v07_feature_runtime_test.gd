extends SceneTree

const SquadRuntime := preload("res://scripts/run/adventurer_squad_runtime.gd")
const HeatmapRuntime := preload("res://scripts/run/tactical_heatmap.gd")
const LocalRoomRules := preload("res://scripts/run/room_rule_runtime.gd")
const TutorialRuntime := preload("res://scripts/tutorial/contextual_tutorial.gd")

func _init() -> void:
    var passages := SecretPassageNetwork.new()
    assert(passages.add_passage(Vector2i(0, 0), Vector2i(4, 0), ["adventurer"], 1.5))
    assert(passages.destination_for(Vector2i.ZERO, ["adventurer"]) == Vector2i(4, 0))
    assert(is_equal_approx(float(passages.navigation_edges(["adventurer"])[0].cost), 1.5))

    var planner := AdventurerRoutePlanner.new()
    var graph := {Vector2i(0, 0): [Vector2i(1, 0)], Vector2i(1, 0): [Vector2i(0, 0)], Vector2i(4, 0): []}
    var route := planner.find_path(graph, Vector2i.ZERO, Vector2i(4, 0), {}, passages.navigation_edges(["adventurer"]))
    assert(route == [Vector2i(0, 0), Vector2i(4, 0)])

    var squad := SquadRuntime.new()
    assert(squad.configure(5).size() == 4)
    assert(squad.formation(1) == &"column")
    assert(bool(squad.use_ability(&"healer", {"missing_health": 30}).ok))
    assert(not bool(squad.use_ability(&"healer", {"missing_health": 30}).ok))

    var heatmap := HeatmapRuntime.new()
    heatmap.record(&"traffic", Vector2i(2, 2), 3.0)
    heatmap.record(&"traffic", Vector2i(3, 2), 1.0)
    heatmap.finish_wave()
    assert(is_equal_approx(heatmap.intensity(&"traffic", Vector2i(2, 2)), 1.0))

    var rooms := LocalRoomRules.new()
    assert(rooms.assign(Vector2i(2, 2), &"altar"))
    assert(is_equal_approx(float(rooms.effects_at(Vector2i(2, 2)).monster_damage_multiplier), 1.2))
    assert(int(rooms.complete_objective(Vector2i(2, 2), true).reward) == 20)

    var tutorial := TutorialRuntime.new()
    assert(not tutorial.next_hint(&"place_trap").is_empty())
    assert(tutorial.next_hint(&"place_trap").is_empty())
    tutorial.set_sandbox(true)
    assert(not tutorial.may_persist_rewards())
    var restored := TutorialRuntime.new()
    restored.restore(tutorial.serialize())
    assert(restored.seen == tutorial.seen and restored.sandbox)

    print("v0.7 feature runtime test passed")
    quit()
