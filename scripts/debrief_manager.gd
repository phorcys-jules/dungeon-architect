class_name DebriefManager
extends RefCounted

# Produces lightweight spatial debrief data (heatmap + moments)
func analyze(replay: Dictionary) -> Dictionary:
	# replay is expected to contain positions[] and events[] in tests
	var positions = replay.get("positions", [])
	var events = replay.get("events", [])
	return {
		"HeatmapSampleCount": positions.size(),
		"KeyMoments": events.size() > 0 ? [events[0]] : [],
	}
