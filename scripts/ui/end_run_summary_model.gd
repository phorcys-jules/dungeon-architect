class_name EndRunSummaryModel
extends RefCounted

func build(run_result: Dictionary, global_stats: GlobalRunStats, progression: Dictionary = {}) -> Dictionary:
    var discoveries: Array = run_result.get("discoveries", [])
    var unlocks: Array = run_result.get("unlocks", [])
    var challenge_progress: Array = run_result.get("challenge_progress", [])
    return {
        "title": "Victoire" if bool(run_result.get("victory", false)) else "Défaite",
        "score": int(run_result.get("score", 0)),
        "wave": int(run_result.get("wave", 0)),
        "duration_seconds": int(run_result.get("duration_seconds", 0)),
        "build_summary": _build_summary(run_result),
        "resources": run_result.get("resources", {}).duplicate(true),
        "captures": int(run_result.get("captures", 0)),
        "discoveries": discoveries.duplicate(true),
        "unlocks": unlocks.duplicate(true),
        "challenge_progress": challenge_progress.duplicate(true),
        "new_record": int(run_result.get("score", 0)) >= global_stats.best_score,
        "global_stats": {
            "runs": global_stats.total_runs,
            "win_rate": global_stats.win_rate(),
            "best_score": global_stats.best_score,
            "best_wave": global_stats.best_wave,
            "favorite_monster": global_stats.most_used(global_stats.favorite_monsters),
            "favorite_synergy": global_stats.most_used(global_stats.favorite_synergies),
        },
        "next_objective": suggest_next_objective(run_result, progression),
    }

func suggest_next_objective(run_result: Dictionary, progression: Dictionary) -> Dictionary:
    var unlocks: Array = run_result.get("unlocks", [])
    if not unlocks.is_empty():
        return {"kind": "unlock", "id": String(unlocks[0]), "label": "Tester le nouveau déblocage"}
    var incomplete: Array = progression.get("incomplete_challenges", [])
    if not incomplete.is_empty():
        return {"kind": "challenge", "id": String(incomplete[0]), "label": "Terminer un défi de run"}
    var undiscovered: Array = progression.get("undiscovered_synergies", [])
    if not undiscovered.is_empty():
        return {"kind": "synergy", "id": String(undiscovered[0]), "label": "Découvrir une nouvelle synergie"}
    if not bool(run_result.get("victory", false)):
        return {"kind": "retry", "id": "retry", "label": "Adapter le donjon et réessayer"}
    return {"kind": "record", "id": "score", "label": "Battre le meilleur score"}

func _build_summary(run_result: Dictionary) -> String:
    var monsters: Array = run_result.get("monster_ids", [])
    var synergies: Array = run_result.get("synergy_ids", [])
    var parts: Array[String] = []
    if not monsters.is_empty():
        parts.append("Monstres : %s" % ", ".join(monsters))
    if not synergies.is_empty():
        parts.append("Synergies : %s" % ", ".join(synergies))
    var biome := String(run_result.get("biome", ""))
    if not biome.is_empty():
        parts.append("Biome : %s" % biome)
    return " | ".join(parts)
