class_name AIDirector
extends RefCounted

# Simple AI Director prototype that adjusts spawn_rate based on recent win rates.
var history := []
var window: int = 10
var target_win_rate: float = 0.5
var spawn_rate: float = 1.0

func record_summary(summary: Dictionary) -> void:
	# summary expected: {"total":int, "victories":int}
	history.append(summary)
	if history.size() > window:
		history.pop_front()

func get_recent_win_rate() -> float:
	var total := 0
	var wins := 0
	for s in history:
		total += int(s.get("total", 0))
		wins += int(s.get("victories", 0))
	if total == 0:
		return 0.0
	return float(wins) / float(total)

func compute_adjustment() -> Dictionary:
	# Adjust spawn_rate to push win_rate toward target_win_rate.
	var current := get_recent_win_rate()
	# Positive diff means players win more than target -> increase difficulty
	var diff := current - target_win_rate
	# change is proportional to diff but clamped
	var delta := clamp(diff * 0.8, -0.5, 0.5)
	spawn_rate = clamp(spawn_rate + delta, 0.2, 3.0)
	var difficulty_modifier := 1.0 + (spawn_rate - 1.0) * 0.6
	return {
		"spawn_rate": spawn_rate,
		"difficulty_modifier": difficulty_modifier,
		"current_win_rate": current,
		"target_win_rate": target_win_rate,
	}

func reset() -> void:
	history.clear()
	spawn_rate = 1.0
