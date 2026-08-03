extends SceneTree

const ComboRuntimeScript := preload("res://scripts/combat/combo_runtime.gd")

func _init() -> void:
    for definition in ComboRuntimeScript.COMBOS:
        var runtime = ComboRuntimeScript.new()
        assert(runtime.apply_state(String(definition.requires[0])).is_empty())
        var result: Dictionary = runtime.apply_state(String(definition.requires[1]))
        assert(String(result.id) == String(definition.id))
        assert(int(result.damage) > 0)
    var deterministic = ComboRuntimeScript.new()
    deterministic.apply_state("tarred")
    assert(String(deterministic.apply_state("burning").id) == "inferno_tar")
    assert(deterministic.total_triggers() == 1)
    print("combo runtime test passed")
    quit(0)
