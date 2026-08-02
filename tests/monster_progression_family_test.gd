extends SceneTree

func _init() -> void:
    var progression := MonsterProgression.new()
    progression.ensure_monster("ghost_a", "spectral", "cunning")
    var level_result: Dictionary = progression.grant_experience("ghost_a", 700)
    assert(int(level_result.level) >= 5)
    assert(progression.choose_evolution("ghost_a", "wraith"))
    assert(not progression.choose_evolution("ghost_a", "poltergeist"))
    var stats: Dictionary = progression.stat_multipliers("ghost_a")
    assert(float(stats.speed) > 1.0)

    var saved: Dictionary = progression.to_dict()
    var restored := MonsterProgression.new()
    restored.from_dict(saved)
    assert(String(restored.monsters["ghost_a"].evolution) == "wraith")

    var social := MonsterFamilyPersonality.new()
    var family: Dictionary = social.family_bonus(["spectral", "spectral", "spectral", "beast"])
    assert(float(family.speed) >= 1.2)
    assert(social.target_bias("loyal") == "treasure")
    assert(float(social.personality_modifiers("aggressive").damage) > 1.0)

    print("monster progression and family test passed")
    quit()
