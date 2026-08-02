extends SceneTree

func _fail(message: String) -> void:
    push_error(message)
    quit(1)

func _init() -> void:
    var director := DifficultyDirector.new()
    var hard := director.scaled_stats({"max_health": 100.0, "attack": 10.0, "speed": 80.0}, DifficultyDirector.Level.HARD, 5)
    if not is_equal_approx(float(hard.max_health), 161.2):
        _fail("Unexpected hard health: %s" % hard.max_health)
        return
    if not is_equal_approx(float(hard.attack), 14.88):
        _fail("Unexpected hard attack: %s" % hard.attack)
        return
    if director.should_spawn_elite(DifficultyDirector.Level.STORY, 5, 0.0):
        _fail("Story mode spawned an elite")
        return
    if not director.should_spawn_elite(DifficultyDirector.Level.NIGHTMARE, 5, 0.1):
        _fail("Nightmare elite roll should succeed")
        return
    if director.elite_affix(7, 4).is_empty():
        _fail("Elite affix is empty")
        return
    if director.boss_phase(0.32) != 3:
        _fail("Expected boss phase 3")
        return
    if director.boss_phase(0.5) != 2:
        _fail("Expected boss phase 2")
        return
    if director.boss_phase(0.9) != 1:
        _fail("Expected boss phase 1")
        return
    var final_phase := director.boss_modifiers(3)
    if int(final_phase.summon_count) != 3:
        _fail("Unexpected summon count: %s" % final_phase.summon_count)
        return
    if bool(final_phase.shield):
        _fail("Final phase shield should be disabled")
        return
    print("Difficulty director test passed")
    quit(0)
