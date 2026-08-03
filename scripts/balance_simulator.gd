class_name BalanceSimulator
extends RefCounted

# Deterministic headless simulator for CI and local use.
# Uses a simple LCG for reproducible pseudo-random numbers across runs.
var _state: int = 1

func _seed_prng(s: int) -> void:
	_state = int(s) & 0x7fffffff

func _randf() -> float:
	# Linear congruential generator (32-bit)
	_state = (1103515245 * _state + 12345) & 0x7fffffff
	return float(_state) / 2147483647.0

func simulate(seed: int, options: Dictionary = {}) -> Dictionary:
	# Deterministic simulation outputs for tests and CI.
	_seed_prng(seed)
	var difficulty := options.get("difficulty", 1.0)
	var victory_chance := 0.5 + (_randf() - 0.5) - (0.05 * difficulty)
	var victory := _randf() < victory_chance
	var duration := 30.0 + (floor(_randf() * 60.0))
	var damage := int(round(_randf() * 120.0 * difficulty))
	var traps_used := 1 + int(floor(_randf() * 5))
	return {
		"seed": seed,
		"victory": victory,
		"duration": duration,
		"damage": damage,
		"traps_used": traps_used,
		"difficulty": difficulty,
	}

func simulate_many(seeds: Array, options: Dictionary = {}) -> Array:
	var results := []
	for s in seeds:
		results.append(simulate(int(s), options))
	return results

func summarize_results(results: Array) -> Dictionary:
	var total := results.size()
	if total == 0:
		return {"total":0}
	var victories := 0
	var total_duration := 0.0
	var total_damage := 0
	for r in results:
		if r.get("victory", false):
			victories += 1
		total_duration += float(r.get("duration", 0))
		total_damage += int(r.get("damage", 0))
	return {
		"total": total,
		"victories": victories,
		"win_rate": float(victories) / float(total),
		"avg_duration": total_duration / float(total),
		"avg_damage": float(total_damage) / float(total),
	}

func generate_report(results: Array) -> Dictionary:
	var summary := summarize_results(results)
	return {
		"summary": summary,
		"results": results,
	}

func to_markdown(report: Dictionary) -> String:
	var s := report.get("summary", {})
	var md := "# Balance simulation report\n\n"
	md += "- Total runs: %d\n" % [s.get("total", 0)]
	md += "- Victories: %d (win rate: %.2f)\n" % [s.get("victories", 0), s.get("win_rate", 0.0)]
	md += "- Avg duration: %.2f\n" % [s.get("avg_duration", 0.0)]
	md += "- Avg damage: %.2f\n\n" % [s.get("avg_damage", 0.0)]
	md += "## Runs\n\n"
	for r in report.get("results", []):
		md += "- seed: %d — victory: %s — duration: %.1f — damage: %d — traps: %d\n" % [r.seed, str(r.victory), float(r.duration), int(r.damage), int(r.traps_used)]
	return md
