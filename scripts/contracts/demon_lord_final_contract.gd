class_name DemonLordFinalContract
extends RefCounted

const REQUIREMENTS := {
	"min_reputation": 100,
	"min_contracts": 20,
	"required_workshop_branches": ["contracts", "blueprints", "forge", "laboratory"],
}

const PHASES := [
	{"id": "outer_defenses", "objective": "survive_waves", "target": 5, "focus": "construction"},
	{"id": "royal_vault", "objective": "protect_treasure", "target": 0.90, "focus": "traps"},
	{"id": "throne_approach", "objective": "capture_elites", "target": 3, "focus": "monsters"},
	{"id": "architect_trial", "objective": "activate_synergies", "target": 4, "focus": "synergies"},
]

var completed := false
var royal_title_unlocked := false
var best_satisfaction := 0.0

func is_available(reputation: int, completed_contracts: int, workshop_levels: Dictionary) -> bool:
	if reputation < int(REQUIREMENTS.min_reputation) or completed_contracts < int(REQUIREMENTS.min_contracts):
		return false
	for branch_id in REQUIREMENTS.required_workshop_branches:
		if int(workshop_levels.get(branch_id, 0)) <= 0:
			return false
	return true

func briefing() -> Dictionary:
	return {"client_id": "demon_lord", "client_name": "Sa Majesté Infernale", "title": "Le donjon ultime", "phases": PHASES.duplicate(true), "reward_title": "Architecte Royal des Ténèbres"}

func evaluate(metrics: Dictionary) -> Dictionary:
	var phase_results: Array[Dictionary] = []
	var passed_count := 0
	for phase in PHASES:
		var passed := _phase_passed(phase, metrics)
		if passed:
			passed_count += 1
		phase_results.append({"id": phase.id, "passed": passed})
	var satisfaction := float(passed_count) / float(PHASES.size())
	best_satisfaction = maxf(best_satisfaction, satisfaction)
	completed = satisfaction >= 0.75
	royal_title_unlocked = satisfaction >= 0.999
	return {"completed": completed, "satisfaction": satisfaction, "grade": _grade(satisfaction), "royal_title_unlocked": royal_title_unlocked, "post_campaign_unlocked": completed, "phase_results": phase_results}

func _phase_passed(phase: Dictionary, metrics: Dictionary) -> bool:
	match String(phase.objective):
		"survive_waves": return int(metrics.get("waves_survived", 0)) >= int(phase.target)
		"protect_treasure": return float(metrics.get("treasure_retained", 0.0)) >= float(phase.target)
		"capture_elites": return int(metrics.get("elites_captured", 0)) >= int(phase.target)
		"activate_synergies": return int(metrics.get("synergies_activated", 0)) >= int(phase.target)
	return false

func _grade(value: float) -> String:
	if value >= 0.999: return "S"
	if value >= 0.75: return "A"
	if value >= 0.50: return "B"
	return "C"

func to_dict() -> Dictionary:
	return {"completed": completed, "royal_title_unlocked": royal_title_unlocked, "best_satisfaction": best_satisfaction}

func from_dict(data: Dictionary) -> void:
	completed = bool(data.get("completed", false))
	royal_title_unlocked = bool(data.get("royal_title_unlocked", false))
	best_satisfaction = clampf(float(data.get("best_satisfaction", 0.0)), 0.0, 1.0)
