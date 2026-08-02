extends SceneTree

func _init() -> void:
    var stats := GlobalRunStats.new()
    var result := {
        "victory": true,
        "score": 1250,
        "wave": 8,
        "duration_seconds": 620,
        "captures": 4,
        "resources": {"gold": 90, "essence": 12},
        "monster_ids": ["ghost", "slime"],
        "synergy_ids": ["ghost_fog"],
        "biome": "crypt",
        "discoveries": ["ghost_fog"],
        "unlocks": ["spider"],
        "challenge_progress": [{"id": "no_traps", "progress": 1.0}],
    }
    stats.record_run(result)
    assert(stats.total_runs == 1)
    assert(stats.victories == 1)
    assert(stats.best_score == 1250)
    assert(stats.best_wave == 8)
    assert(stats.most_used(stats.favorite_monsters) == "ghost")

    var model := EndRunSummaryModel.new()
    var summary := model.build(result, stats, {
        "incomplete_challenges": ["one_family"],
        "undiscovered_synergies": ["slime_ice"],
    })
    assert(summary.title == "Victoire")
    assert(summary.new_record)
    assert(String(summary.build_summary).contains("ghost"))
    assert(summary.next_objective.kind == "unlock")
    assert(summary.next_objective.id == "spider")

    var restored := GlobalRunStats.new()
    restored.from_dict(stats.to_dict())
    assert(restored.total_runs == 1)
    assert(restored.best_score == 1250)
    assert(is_equal_approx(restored.win_rate(), 1.0))

    var failure := result.duplicate(true)
    failure.victory = false
    failure.score = 200
    failure.unlocks = []
    var retry_summary := model.build(failure, restored, {})
    assert(retry_summary.next_objective.kind == "retry")

    print("end run summary test passed")
    quit()
