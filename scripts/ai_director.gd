class_name AIDirector
extends RefCounted

# Simple AI Director prototype that adjusts spawn_rate based on recent win rates.
var history: Array[Dictionary] = []
var window: int = 10
var target_win_rate: float = 0.5
var spawn_rate: float = 1.0

func record_summary(summary: Dictionary) -> void:
	history.append(summary)
	if history.size() > window:
		history.pop_front()

func get_recent_win_rate() -> float:
	var total := 0
	var wins := 0
	for summary in history:
		total += int(summary.get("total", 0))
		wins += int(summary.get("victories", 0))
	if total == 0:
		return 0.0
	return float(wins) / float(total)

func compute_adjustment() -> Dictionary:
	var current := get_recent_win_rate()
	var difference := current - target_win_rate
	var delta := clampf(difference * 0.6, -0.3, 0.3)
	spawn_rate = clampf(spawn_rate + delta, 0.2, 3.0)
	var difficulty_modifier := 1.0 + (spawn_rate - 1.0) * 0.5
	return {
		"spawn_rate": spawn_rate,
		"difficulty_modifier": difficulty_modifier,
		"current_win_rate": current,
		"target_win_rate": target_win_rate,
	}

func reset() -> void:
	history.clear()
	spawn_rate = 1.0

func to_dict() -> Dictionary:
	return {
		"history": history.duplicate(true),
		"window": window,
		"target_win_rate": target_win_rate,
		"spawn_rate": spawn_rate,
	}

func from_dict(data: Dictionary) -> void:
	history.assign(data.get("history", []))
	window = int(data.get("window", window))
	target_win_rate = float(data.get("target_win_rate", target_win_rate))
	spawn_rate = float(data.get("spawn_rate", spawn_rate))

func get_spawn_rate() -> float:
	return spawn_rate

func set_params(new_window: int, new_target: float) -> void:
	window = maxi(new_window, 1)
	target_win_rate = clampf(new_target, 0.0, 1.0)

func apply_to_wave(wave: Dictionary) -> Dictionary:
	var output := wave.duplicate(true)
	if output.has("release_delay"):
		output["release_delay"] = float(output["release_delay"]) / maxf(0.001, spawn_rate)
	if output.has("monster_count"):
		output["monster_count"] = int(round(float(output["monster_count"]) * spawn_rate))
	if output.has("elite_chance"):
		var elite_multiplier := 1.0 + (spawn_rate - 1.0) * 0.4
		output["elite_chance"] = clampf(float(output["elite_chance"]) * elite_multiplier, 0.0, 1.0)
	return output
