extends SceneTree

func _init() -> void:
    var director := DifficultyDirector.new()
    var hard := director.scaled_stats({"max_health": 100.0, "attack": 10.0, "speed": 80.0}, DifficultyDirector.Level.HARD, 5)
    if not is_equal_approx(float(hard.max_health), 161.2) or not is_equal_approx(float(hard.attack), 14.88):
        quit(1)
        return
    if director.should_spawn_elite(DifficultyDirector.Level.STORY, 5, 0.0):
        quit(1)
        return
    if not director.should_spawn_elite(DifficultyDirector.Level.NIGHTMARE, 5, 0.1):
        quit(1)
        return
    if director.elite_affix(7, 4).is_empty():
        quit(1)
        return
    if director.boss_phase(0.32) != 3 or director.boss_phase(0.5) != 2 or director.boss_phase(0.9) != 1:
        quit(1)
        return
    var final_phase := director.boss_modifiers(3)
    if int(final_phase.summon_count) != 3 or bool(final_phase.shield):
        quit(1)
        return
    print("Difficulty director test passed")
    quit(0)
