extends SceneTree

func _init() -> void:
    var ids: Array[StringName] = []
    for id in CustomChallengeRuntime.MUTATORS:
        ids.append(StringName(id))
    ids.sort()
    var checked := 0
    for seed_value in 100:
        var selected: Array[StringName] = [ids[seed_value % ids.size()]]
        var runtime := CustomChallengeRuntime.new()
        var result := runtime.configure(seed_value, &"crypt", &"sun_order", "paladin_captain", selected)
        assert(bool(result.ok))
        var code := runtime.export_code()
        var restored := CustomChallengeRuntime.new()
        assert(bool(restored.import_code(code).ok))
        assert(int(restored.configuration.seed) == seed_value)
        checked += 1
    assert(checked == 100)
    print("v0.8 custom challenge matrix test passed")
    quit()
