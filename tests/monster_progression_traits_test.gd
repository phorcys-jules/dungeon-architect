extends SceneTree

func _init() -> void:
    var progression := MonsterProgression.new()
    progression.setup("ghost_alpha", "spectral")
    assert(progression.grant_experience(150) == 3)
    assert(progression.available_evolutions().has("wraith"))
    assert(progression.choose_evolution("wraith"))
    assert(not progression.choose_evolution("poltergeist"))
    var progression_modifiers: Dictionary = progression.stat_modifiers()
    assert(float(progression_modifiers.speed_multiplier) > 1.0)

    var restored := MonsterProgression.new()
    restored.from_dict(progression.to_dict())
    assert(restored.evolution == "wraith")
    assert(restored.level == progression.level)

    var traits_a := MonsterTraits.new()
    var traits_b := MonsterTraits.new()
    assert(traits_a.generate(42) == traits_b.generate(42))
    var modifiers: Dictionary = traits_a.combined_modifiers()
    assert(modifiers.has("health_multiplier"))
    assert(modifiers.has("cooperation_bonus"))

    var restored_traits := MonsterTraits.new()
    restored_traits.from_dict(traits_a.to_dict())
    assert(restored_traits.assigned == traits_a.assigned)

    print("monster progression and traits test passed")
    quit()
