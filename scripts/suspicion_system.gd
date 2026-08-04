class_name SuspicionSystem
extends RefCounted

# Suspicion considers intelligence, observed traps, and shared squad info.
func compute_suspicion(profile: Dictionary, observations: Array, shared_info: Array = []) -> float:
	var base: float = float(profile.get("intelligence", 0.5))
	var observation_score: float = 0.0
	for observation: Variant in observations:
		if observation is Dictionary:
			observation_score += float((observation as Dictionary).get("weight", 1.0))
		else:
			# Legacy observations represented only the fact that something was seen.
			observation_score += 1.0
	var shared_score: float = 0.0
	for shared_observation: Variant in shared_info:
		if shared_observation is Dictionary:
			shared_score += float((shared_observation as Dictionary).get("reliability", 0.5)) * 0.2
	var increase: float = clampf(observation_score * 0.05 + shared_score, 0.0, 1.0)
	return clampf(base + increase, 0.0, 1.0)
