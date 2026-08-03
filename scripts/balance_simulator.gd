class_name BalanceSimulator
extends RefCounted

# Minimal deterministic headless simulator for CI and local use.
func simulate(seed: int, options: Dictionary = {}) -> Dictionary:
	# simple deterministic outputs for tests
	var victory := (seed % 3) != 0
	return {
		"seed": seed,
		"victory": victory,
		"duration": 45.0 + (seed % 20),
		"damage": (seed * 7) % 100,
		"traps_used": 1 + (seed % 4),
	}
