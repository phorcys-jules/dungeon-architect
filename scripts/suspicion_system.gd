class_name SuspicionSystem
extends RefCounted

# Simple suspicion gauge per adventurer
func compute_suspicion(profile: Dictionary, observations: Array) -> float:
	var base := profile.get("intelligence", 0.5)
	var mods := observations.size() * 0.05
	return clamp(base + mods, 0.0, 1.0)
