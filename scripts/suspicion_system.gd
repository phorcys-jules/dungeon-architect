class_name SuspicionSystem
extends RefCounted

# Suspicion considers intelligence, observed traps, and shared squad info
func compute_suspicion(profile: Dictionary, observations: Array, shared_info: Array = []) -> float:
	var base := float(profile.get("intelligence", 0.5))
	var obs_score := 0.0
	for o in observations:
		obs_score += float(o.get("weight", 1.0))
	var shared_score := 0.0
	for s in shared_info:
		shared_score += float(s.get("reliability", 0.5)) * 0.2
	var value := base + clamp(obs_score * 0.05 + shared_score, 0.0, 1.0)
	return clamp(value, 0.0, 1.0)
